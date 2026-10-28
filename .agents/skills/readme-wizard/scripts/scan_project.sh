#!/usr/bin/env bash
# Local-only metadata scanner. Requires Bash and Python 3.8+; Git is optional.
# Usage: bash scan_project.sh [project-directory]
set -euo pipefail
if [[ $# -gt 1 ]]; then
  printf 'Usage: %s [project-directory]\n' "$0" >&2
  exit 2
fi
if command -v python3 >/dev/null 2>&1; then
  scanner_python=python3
elif command -v python >/dev/null 2>&1; then
  scanner_python=python
else
  printf 'Error: Python 3.8+ is required.\n' >&2
  exit 1
fi
exec "$scanner_python" - "${1:-.}" <<'PYTHON'
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlsplit

if sys.version_info < (3, 8):
    sys.exit('Error: Python 3.8+ is required.')
root = Path(sys.argv[1]).expanduser().resolve()
if not root.is_dir():
    sys.exit('Error: project path must be an existing directory.')

def read(path):
    try:
        return path.read_text(encoding='utf-8-sig', errors='replace')
    except OSError:
        return ''

def load_json(name):
    try:
        value = json.loads(read(root / name))
        return value if isinstance(value, dict) else {}
    except ValueError:
        return {}

def string(value):
    return value if isinstance(value, str) else ''

def toml_metadata(name, sections):
    # Prefer the standard TOML parser on Python 3.11+; on older Python,
    # conservatively read only single-line quoted fields in known sections.
    text = read(root / name)
    try:
        import tomllib
        data = tomllib.loads(text)
        for section in sections:
            part = data
            for key in section.split('.'):
                part = part.get(key, {}) if isinstance(part, dict) else {}
            if isinstance(part, dict) and part:
                return part
    except (ImportError, ValueError):
        pass
    current, result = '', {}
    for line in text.splitlines():
        header = re.match(r'^\s*\[([^\[\]]+)\]\s*(?:#.*)?$', line)
        if header:
            current = header[1]
        elif current in sections:
            field = re.match(r'''^\s*(name|description|license)\s*=\s*(['"])(.*?)\2\s*(?:#.*)?$''', line)
            if field and not field[3].startswith(field[2] * 2):
                result.setdefault(field[1], field[3])
    return result

package = load_json('package.json')
metadata = package or toml_metadata('Cargo.toml', ['package']) or toml_metadata('pyproject.toml', ['project', 'tool.poetry'])
module_match = re.search(r'^\s*module\s+(?:"([^"\n]+)"|([^\s/][^\s]*))', read(root / 'go.mod'), re.M)
module = (module_match[1] or module_match[2]) if module_match else ''
name = string(metadata.get('name'))
if not name and module:
    name = re.sub(r'/v[0-9]+$', '', module).rstrip('/').split('/')[-1]
name = name or root.name
license_name = string(metadata.get('license'))
if isinstance(metadata.get('license'), dict):
    license_name = string(metadata['license'].get('text'))
for filename in ('LICENSE', 'LICENSE.md', 'LICENSE.txt', 'COPYING'):
    text = read(root / filename)
    if not text:
        continue
    for pattern, label in ((r'\bMIT License\b', 'MIT'), (r'Apache License[\s\S]{0,150}Version 2\.0', 'Apache-2.0'), (r'GNU AFFERO GENERAL PUBLIC LICENSE', 'AGPL'), (r'GNU LESSER GENERAL PUBLIC LICENSE', 'LGPL'), (r'GNU GENERAL PUBLIC LICENSE', 'GPL'), (r'\bBSD\b', 'BSD'), (r'\bISC License\b', 'ISC')):
        if re.search(pattern, text, re.I):
            license_name = label
            break
    break

manager = ''
for candidate, files in (
    ('pnpm', ('pnpm-lock.yaml',)), ('yarn', ('yarn.lock',)),
    ('npm', ('package-lock.json', 'npm-shrinkwrap.json')),
    ('bun', ('bun.lock', 'bun.lockb')), ('cargo', ('Cargo.toml', 'Cargo.lock')),
    ('pipenv', ('Pipfile', 'Pipfile.lock')), ('poetry', ('poetry.lock',)),
    ('pip', ('requirements.txt', 'pyproject.toml', 'setup.py', 'setup.cfg')),
    ('go', ('go.mod', 'go.sum')),
    ('gradle', ('build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradlew')),
    ('deno', ('deno.json', 'deno.jsonc', 'deno.lock')),
):
    if any((root / file).is_file() for file in files):
        manager = candidate
        break
if not manager:
    declared = string(package.get('packageManager')).split('@')[0]
    manager = declared if declared in ('npm', 'yarn', 'pnpm', 'bun') else ('npm' if package else '')

remote, owner, repo = '', '', ''
try:
    # --get reads configuration only; it never contacts the remote.
    result = subprocess.run(['git', '-C', str(root), 'config', '--get', 'remote.origin.url'], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=5)
    remote = result.stdout.strip() if result.returncode == 0 else ''
except (OSError, subprocess.SubprocessError):
    pass
if remote:
    if '://' in remote:
        parsed = urlsplit(remote)
        path = parsed.path if parsed.scheme in ('http', 'https', 'ssh', 'git') else ''
    else:
        match = re.match(r'(?:[^/@:]+@)?[^/:]+:(.+)', remote)
        path = match[1] if match else ''
    segments = path.strip('/').split('/') if path else []
    if len(segments) >= 2:
        owner, repo = '/'.join(segments[:-1]), re.sub(r'\.git$', '', segments[-1])

workflows_dir = root / '.github/workflows'
try:
    workflows = sorted(p.name for p in workflows_dir.iterdir() if p.is_file() and p.suffix in ('.yml', '.yaml'))
except OSError:
    workflows = []
provider = 'github-actions' if workflows else ''
if not provider:
    for candidate, filename in (('circleci', '.circleci/config.yml'), ('travis', '.travis.yml'), ('gitlab', '.gitlab-ci.yml'), ('jenkins', 'Jenkinsfile'), ('azure-pipelines', 'azure-pipelines.yml')):
        if (root / filename).is_file():
            provider = candidate
            break

excluded = {'node_modules', 'dist', 'build', 'target', '__pycache__', 'venv', 'env', 'coverage', 'vendor', 'out', 'site-packages'}
def visible_entries(folder):
    try:
        return sorted((p for p in folder.iterdir() if not p.name.startswith('.') and not p.is_symlink() and not (p.is_dir() and p.name in excluded) and p.suffix not in ('.pyc', '.pyo')), key=lambda p: (not p.is_dir(), p.name))
    except OSError:
        return []

def tree(folder, depth=0, prefix=''):
    lines = []
    entries = visible_entries(folder)
    for index, entry in enumerate(entries):
        last = index == len(entries) - 1
        lines.append(prefix + ('\u2514\u2500\u2500 ' if last else '\u251c\u2500\u2500 ') + entry.name + ('/' if entry.is_dir() else ''))
        if entry.is_dir() and depth < 1:
            lines.extend(tree(entry, depth + 1, prefix + ('    ' if last else '\u2502   ')))
    return lines

patterns = {
    'youtube': r'https?://(?:www\.)?youtube\.com/(?:@[\w-]+|(?:c|channel|user)/[\w-]+)',
    'discord': r'https?://(?:www\.)?(?:discord\.gg/|discord\.com/invite/)[\w-]+',
    'twitter': r'https?://(?:www\.)?(?:twitter\.com|x\.com)/[A-Za-z0-9_]+',
    'linkedin': r'https?://(?:www\.)?linkedin\.com/(?:in|company)/[\w-]+',
    'bluesky': r'https?://bsky\.app/profile/[\w.-]+',
    'twitch': r'https?://(?:www\.)?twitch\.tv/[\w-]+',
}
social = {key: [] for key in patterns}
# Search local documentation and metadata, not executable source examples,
# hidden agent instructions, dependency folders, or linked directories.
text_extensions = {'.md', '.mdx', '.rst', '.txt', '.json', '.jsonc', '.toml', '.yaml', '.yml', '.html'}
def scan_social(folder):
    for entry in visible_entries(folder):
        if entry.is_dir():
            scan_social(entry)
        elif entry.suffix.lower() in text_extensions or entry.name.lower() == 'readme':
            for key, pattern in patterns.items():
                for match in re.finditer(pattern, read(entry), re.I):
                    url = match[0].rstrip('.')
                    # Exclude well-known action routes, which are not accounts.
                    if key == 'twitter' and url.rsplit('/', 1)[-1].lower() in ('intent', 'share', 'home', 'search', 'i'):
                        continue
                    if url not in social[key]:
                        social[key].append(url)
scan_social(root)
output = {
    'project_name': name,
    'description': string(metadata.get('description')),
    'license': license_name,
    'git_remote': remote,
    'owner': owner,
    'repo': repo,
    'module_path': module,
    'package_manager': manager,
    'ci': {'provider': provider, 'workflows': workflows},
    'social_links': social,
    'directory_structure': '\n'.join(tree(root)),
}
print(json.dumps(output, ensure_ascii=True, indent=2))
PYTHON

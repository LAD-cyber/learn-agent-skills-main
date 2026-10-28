---
name: readme-wizard
description: >-
  Generate or improve project READMEs. Use this skill whenever someone mentions README, wants to improve their repo's first impression or make it look more professional, or asks about shields.io badges, star history charts, contributor avatars, documentation tables, project structure trees, or Mermaid architecture diagrams for their project, even if they never say the word "README".
---

# README Wizard

Create or improve the project's README using real repository data. Preserve useful existing information and match the project's language and purpose.

## 1. Inspect the project

Read the existing README, manifests, lockfiles, license files, documentation, and CI configuration. Use local Git configuration or `git remote get-url origin` to identify the remote owner and repository.

Detect:
- Project name and description from source files and manifests such as package.json, pyproject.toml, Cargo.toml, or go.mod.
- License from the actual license file and package metadata.
- Package manager from lockfiles and configuration: npm, yarn, pnpm, bun, pip, poetry, cargo, go, or the project's equivalent.
- CI provider and actual workflow filenames from files such as .github/workflows/, .gitlab-ci.yml, or other CI configuration.
- Available release or package version, documented installation and run commands, documentation paths, and existing social links.

Read references/readme-best-practices.md before writing. It covers structure, tone, project-type adaptation, and common pitfalls. Run `bash scripts/scan_project.sh /path/to/project` from this skill folder to collect local-only JSON metadata (requires Bash and Python 3.8+; Git is optional). It detects package managers, parses the Go module path, reads local CI and social links, and produces a two-level tree with hidden/generated directories excluded. It never calls external APIs. Unknown fields are empty strings or arrays; social links are arrays grouped by platform. Review the source files to confirm context and commands before writing.

## 2. Build or improve the README

Use [assets/readme-template.md](assets/readme-template.md) as the base structure. Replace every `{{PLACEHOLDER}}` with actual, verified project data. Adapt rather than copy blindly: drop sections that do not apply and adjust the tone and emphasis to match the project type, following the best-practices reference.

- Read [assets/badges.json](assets/badges.json) for the `status`, `social`, and `extras` catalog. Replace its placeholders with verified values and omit badges whose required data is unknown; use `style=for-the-badge` throughout.
- Follow the template's HTML comment for **Connect**: include the section ONLY if the project has social links; remove the heading, content, and comment entirely when none exist.
- Derive Quick Start commands from the actual package manager, scripts, and entry points; explain required configuration. For documentation projects, provide the first reading or exercise step instead of inventing a runtime.
- Generate the project tree from the filesystem, showing directories before files, alphabetizing each group, marking directories with `/`, and excluding generated output and dependencies.
- Link to real documentation and the existing contribution process. Keep contributor avatars and Star History only when a GitHub owner and repository are known; include a license only when verified.

Do not fabricate missing metadata, documentation, contribution policies, or external service identifiers. Omit unsupported elements and mention material missing information in the completion report instead of leaving empty sections or placeholders. Keep the README proportional to the project.

Only read [assets/diagrams.md](assets/diagrams.md) when an architecture diagram is requested or useful for explaining multiple components or clear data flow. Adapt a suitable template to the actual code and relationships; omit nonexistent components and skip diagrams for simple projects.

## 3. Review the result

Check that commands match project files, documentation links resolve locally, badge targets match real metadata, and all template placeholders are replaced. Use relevant assertions in [evals/evals.json](evals/evals.json) as a review checklist while respecting missing data and project scope.

Save the README and briefly report the changes and any information that could not be verified. Do not claim that commands or external links were tested unless they were actually checked.

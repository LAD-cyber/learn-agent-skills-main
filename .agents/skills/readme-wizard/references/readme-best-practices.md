# README Best Practices

## Table of Contents

- [Structure and Order](#structure-and-order)
- [Writing Tone](#writing-tone)
- [Adapting to Project Type](#adapting-to-project-type)
- [Badge Best Practices](#badge-best-practices)
- [Common Pitfalls](#common-pitfalls)

## Structure and Order

Lead with the project's purpose, then help the reader run it before presenting reference material. Follow the section order below; keep status badges in the hero and social badges in Connect.

Not every project needs every section. Omit sections without useful, verified content, and combine sections where that improves navigation. A small script may need only a title, description, usage, and license; a documentation repository may emphasize its learning path instead of installation.

Use this exact relative order for applicable sections; omit unsupported sections rather than adding empty headings.

1. **Hero:** Centered project name, one-line tagline, and supported status badges; optionally include an existing screenshot or demo link.
2. **What is this?:** Two or three sentences describing the problem solved, intended audience, and concrete capabilities.
3. **Quick Start:** Prerequisites, real install/setup/run commands, required configuration, and the expected first result. For documentation projects, link to the first lesson instead of inventing a runtime.
4. **Project Structure:** An accurate, focused tree with directories first, alphabetical ordering within groups, and trailing `/` markers on directories.
5. **Documentation:** A table of links to real tutorials, guides, API references, or package READMEs, each with a short description.
6. **Contributing:** The actual contribution process and, when a GitHub repository is known, contributor avatars from `https://contrib.rocks/image?repo=OWNER/REPO` linked to `https://github.com/OWNER/REPO/graphs/contributors`.
7. **Connect:** Social link badges for verified project accounts only; omit the section when none exist.
8. **License:** The verified license name and a link to the actual license file; do not assume a license if none is declared.
9. **Footer:** A Star History chart from `https://api.star-history.com/svg?repos=OWNER/REPO&type=Date`, linked to `https://star-history.com/#OWNER/REPO&Date`, when the GitHub repository is known.

When useful, put an architecture diagram with the explanation in What is this? or beside Project Structure without disrupting the core section order. Preserve valuable existing setup or usage details under the appropriate section.

## Writing Tone

Write concisely, directly, and in active voice. Match the project's existing language and audience; explain concrete behavior rather than making marketing claims.

| Topic | Bad | Good |
|-------|-----|------|
| Description | An amazing, revolutionary developer tool. | A CLI that converts Markdown to PDF with syntax highlighting and batch processing. |
| Instructions | You might want to consider installing the dependencies. | Run `pnpm install` to install dependencies. |
| Specificity | A project built with React. | A browser app for tracking household expenses and exporting monthly reports. |
| Results | Easily process your files. | Run `convert notes.md` to write `notes.pdf` beside the source file. |

The commands above illustrate writing style, not commands to copy into unrelated projects. Use the actual project's commands.

## Adapting to Project Type

- **Libraries/frameworks:** Lead with installation and a minimal import/use/result example. Show supported prerequisites and link to real API documentation; keep the first example small enough to understand immediately.
- **Web apps:** Include an existing screenshot or demo when available. Cover clone, install, required environment configuration, and the actual development command; describe deployment only when the project documents it.
- **Documentation repos:** Explain what readers will learn, provide an ordered reading path, and make the documentation table and directory tree the primary navigation. State when no dependency installation or application runtime is required.
- **Small utilities:** Favor a short description, exact invocation, and concrete input/output example. Skip architecture diagrams, large trees, and contribution boilerplate when they add no useful information.
- **Monorepos:** Explain the purpose of each package, link package READMEs, identify where newcomers should start, and show actual workspace commands. Use a Mermaid diagram when package relationships need explanation.

## Badge Best Practices

All badge image URLs must use `style=for-the-badge`. Three to five status badges is the sweet spot when that many are supported by project data; fewer is better than inventing metadata. Group status badges in the hero and social badges in Connect.

Read [../assets/badges.json](../assets/badges.json) for the status, social, and extras catalog, exact URL templates, placeholder handling, and badge-specific requirements. Keep the templates there as the single source of truth. Only use verified project accounts and identifiers; omit badges whose required values are unknown.

## Common Pitfalls

- **Leftover placeholders:** Replace template markers such as `{{PROJECT_NAME}}`, example owner/repository identifiers, TODO notes, and filler prose. Review links as well as visible text.
- **Fabricated badges:** Do not add CI, release, package, or social badges without evidence that their targets exist. A broken badge is worse than no badge.
- **Outdated install commands:** Derive commands from current manifests, lockfiles, scripts, and setup instructions. Do not switch pnpm projects to npm or invent a start script.
- **Generic descriptions:** Explain what the project does and for whom; naming its framework alone is not a useful introduction.
- **Overly long READMEs:** Scale the document to the project. Move detailed reference material to existing documentation and avoid filling a small script's README with empty sections.
- **Missing Quick Start:** Give readers a concrete first action and expected result, whether that is running a tool or opening the first tutorial.

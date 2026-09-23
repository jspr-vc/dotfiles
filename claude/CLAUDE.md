# Global Instructions

## Python

- pyenv + pyenv-virtualenv, Python **3.10**. Stay on 3.10 unless told to upgrade.
- `python` and `pip` are aliases for `pyenv exec python` / `pyenv exec pip`; call them bare. Never system python.
- The active pyenv virtualenv is the isolation. Install deps with `pip install -r requirements.txt`.
- Type hints on all Python code.

## JavaScript / TypeScript

- **bun** for everything: install, run, test, build.

## Docker

- Docker for infrastructure services (Postgres, Redis, RabbitMQ). Application code runs locally unless the project requires otherwise.

## Infrastructure

- **OpenTofu** (`tofu`) for IaC.

## Git and GitHub

- **Conventional commits** (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `ci:`, `perf:`).
- Before feature work on `main`, `staging` or `dev`: pull from remote, then branch. Commit and push to those branches only when told to.
- **`gh`** for PRs, issues and checks.

## Code

- Self-documenting code. Comment only where the logic is non-obvious.
- Touch only code you're changing: no docstrings, comments or annotations added to untouched code.
- Run tests only when asked.

## Writing (responses, prose, docs, letters, copy)

- My voice: direct and concise. Say each thing once, then stop. Explain in depth only when asked.
- Punctuate with commas and periods; never em dashes.
- Banned AI tells: "delve", "leverage", "robust", "tapestry", "it's not just X, it's Y", "I'd welcome the chance to", adjective triads, closing paragraphs that restate the opening.
- Copy (landing pages, headings, buttons, empty states, marketing) states the concrete thing, the way you'd say it to a person. Banned: slogans, punchy fragments, three-word taglines, rhetorical-question headers, imperative hype ("Unlock", "Discover", "Transform", "Level up").

## Scaffolding

Before scaffolding any new project or app, read `~/.claude/docs/scaffold-strategy.md`: monorepo and single-app shapes, tooling, the Neon Postgres driver, db naming conventions, local infra.

## Background (CVs, cover letters, applications)

- Hands-on with **Terraform** and **AWS CDK**. Never list these as gaps.

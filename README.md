# tmuxinator-team-workflows

Share **tmuxinator workflows across teams** while allowing developers to customize their own local development environment.

This repository provides a lightweight framework for distributing tmuxinator project workflows so teams can **start complex development environments with a single command**, while keeping flexibility for personal setups.

tmuxinator itself is **intentionally not abstracted away**. Developers interact directly with tmuxinator so they can use the full power of **tmux** and **tmuxinator** without learning an additional wrapper tool.

---

# The problem

Modern development environments are often complex.

Projects frequently require starting multiple services such as:

- backend APIs
- frontend development servers
- background workers
- databases or containers
- log watchers
- build tools

Developers often start these manually across multiple terminals.

This leads to:

- slower onboarding for new developers
- inconsistent development setups
- repetitive manual work when switching projects

Teams often solve this individually, but rarely **share the workflow itself**.

---

# The solution

**tmuxinator-team-workflows** allows teams to share development workflows using tmuxinator configuration files.

This repository adds a lightweight collaboration layer around tmuxinator:

- teams define shared workflows
- developers install them locally
- developers can extend them without modifying shared configuration

A full development environment can then start with one command:

```bash
tmuxinator start example-project
```

tmuxinator remains the execution engine, so **all tmux and tmuxinator features remain available**.

---

# Developer experience

This approach improves developer experience for both onboarding and daily development.

Developers spend less time managing terminals and setup scripts, and more time building features.

Benefits include:

- faster onboarding for new developers
- consistent project startup
- easier switching between projects
- flexibility for personal development workflows

**Less hassle, more action.**

---

# Team workflows with personal customization

This project separates **team workflows** from **personal developer customization**.

Typical flow:

1. The team defines a workflow in `templates/`
2. Developers install workflows using `install.sh`
3. Developers can extend workflows locally
4. Workflows run using tmuxinator

Example:

```bash
tmuxinator start example-project
```

Shared services start automatically while developers can run additional tools locally.

The demo project included in this repository demonstrates this workflow model.

---

# Quick Start

Typical workflow for teams using this repository:

1. Fork this repository
2. Add tmuxinator workflows to `templates/`
3. Share the repository with your team
4. Developers install it once

```bash
bash install.sh
```

Start a workflow:

```bash
tmuxinator start example-project
```

List available workflows:

```bash
tmuxinator list
```

---

# How it works

This repository separates **shared configuration** from **developer customization**.

| Folder | Purpose |
|------|------|
| templates/ | Shared tmuxinator workflows maintained by the team |
| local/ | Developer-specific working copies |
| .internal/ | Installer metadata (created automatically) |

Workflow:

1. `install.sh` copies workflows from `templates/` into `local/`
2. Symlinks are created in:

```
~/.config/tmuxinator
```

3. Those symlinks point to files in `local/`

Developers modify the files in `local/`, not the shared templates.

### Architecture at a glance

```text
Team workflow
   │
   ▼
templates/
   │
install.sh
   │
   ▼
local/  → developer customization
   │
   ▼
~/.config/tmuxinator
   │
   ▼
tmuxinator start <project>
```

---

# Repository structure

```text
.
├── install.sh
├── uninstall.sh
├── templates/
│   └── example-project.yml
├── local/
├── .gitignore
└── README.md
```

After installation an internal folder is created:

```text
.internal/
  env.sh
  install-manifest.txt
  README
```

This directory stores installer metadata.

---

# Installation

Clone the repository and run:

```bash
bash install.sh
```

The installer will:

- check if **tmux** is installed
- check if **tmuxinator** is installed
- install missing dependencies when possible
- ask for your repositories root directory
- create environment variable `REPOSITORIES_ROOT`
- copy workflows from `templates/` into `local/`
- create symlinks in `~/.config/tmuxinator`

Example folder layout:

```text
~/Development
├── backend-service
├── frontend-app
└── tmuxinator-team-workflows
```

This works well when the repository is cloned next to your projects, but it is **not required**.

---

# Using REPOSITORIES_ROOT

Templates should use the `REPOSITORIES_ROOT` environment variable.

Example:

```yaml
name: example-project

root: <%= ENV.fetch("REPOSITORIES_ROOT") %>/example-project

windows:
  - app:
      panes:
        - npm run dev
```

This allows developers to keep repositories in different local directories while still sharing the same configuration.

---

# Customization model

This project intentionally separates **team configuration** from **developer customization**.

## Team workflow changes

Team-wide workflow changes should be made in:

```
templates/
```

Examples:

- adding services
- changing workspace layout
- adding shared commands

---

## Developer customization

Developers modify their own copy in:

```
local/
```

Templates are copied into `local/` so developers can safely modify them.

Typical personal changes:

- opening editors automatically
- adjusting pane layouts
- modifying commands
- experimenting locally

If a change benefits the team, move it back into `templates/`.

---

## Optional override files

Templates can optionally support **developer override files**.

Overrides allow developers to **add additional panes or commands** without editing the base template.

Example override:

```
local/example-project.override.yml
```

Example content:

```yaml
- personal:
    panes:
      - bash -lc 'echo "Personal override loaded"; exec $SHELL -l'
```

Try the example override included in this repository:

```bash
cp local/example-project.override.example.yml local/example-project.override.yml
tmuxinator start example-project
```

Overrides are useful for **adding tools or commands**.

For deeper changes, editing the copied file in `local/` is usually easier.

---

# Updating workflows

When templates change:

```bash
git pull
bash install.sh
```

The installer detects existing installations and asks before overwriting local files.

---

# Uninstall

To remove the setup:

```bash
bash uninstall.sh
```

This removes:

- tmuxinator symlinks
- shell configuration added during installation
- installer metadata in `.internal`

Local files are only removed if confirmed.

---

# Requirements

The installer ensures the following dependencies exist:

- tmux
- tmuxinator

---

# Git ignore rules

Recommended `.gitignore`:

```gitignore
/local/*
!/local/example-project.override.example.yml
/.internal/
```

---

# References

tmuxinator

https://github.com/tmuxinator/tmuxinator

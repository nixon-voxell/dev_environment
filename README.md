# Dev Environment

Minimal nu script to setup and update development environment in [Nushell](https://www.nushell.sh/).

## How to use?

1. Install [Nushell](https://www.nushell.sh/).
2. In Nushell, run `nu setup.nu`.

## Steps

### Step `#1`: Check package installations.

This script requires [`rustup`](https://www.rust-lang.org/tools/install) and `cargo` to be installed.

### Step `#2`: Install essential 🦀 Rust tools.

These are the rust tools that will be installed during the setup:

```nu
╭───┬───────────╮
│ 0 │ eza       │
│ 1 │ fd-find   │
│ 2 │ mprocs    │
│ 3 │ git-graph │
│ 4 │ git-delta │
│ 5 │ bacon     │
╰───┴───────────╯
```

### Step `#3`: Setup helix.

[Helix](https://helix-editor.com/) will be installed/updated.

### Step `#4`: Setup configurations.

Currently, Windows is the only system host that is being supported for this step.

Included configurations:
1. Terminal
2. Helix
3. Git

### Step `#5`: Setup development directories.

A `develop` directory will be created outside of this directory with these subfolders:

```nu
..\develop
├── notes
├── other
├── projects
└── temp
```

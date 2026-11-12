# Stowaway

Stowaway is a skeleton for zsh dotfiles on macOS, built on
[GNU Stow](https://www.gnu.org/software/stow/). It splits your configuration
into small modules and lets each machine choose the modules it needs.

By organizing dotfiles this way, you can keep one repository for every
machine you use. A work laptop and a home desktop can share a common base
and differ only where they need to.

## Getting started

This repository is a GitHub template. Click **Use this template** to create
your own copy, then clone it wherever you keep your dotfiles.

```sh
git clone https://github.com/<you>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Stowaway needs zsh, which macOS includes, and GNU Stow 2.4 or later, which
you install yourself. Earlier versions of Stow have bugs with `--dotfiles`
that can stop `switch` from unlinking `dot-` directories, so `switch` warns
when it finds one. Stowaway doesn't install Stow or change your `PATH`.
Every command runs from the repository as `./stowaway`.

## Core concepts

Your configuration is built from three kinds of directory.

- **Module** - one tool's configuration, in `modules/<name>`. A module holds
  the files to link into your home directory and the scripts that install
  the tool and load it into your shell.
- **Role** - a named group of modules, in `roles/<name>`. A role can also
  include other roles, so `work` can build on `base`.
- **Host** - one machine, in `hosts/<name>`. A host lists the roles and
  modules that machine uses.

Hosts and roles are directories of symbolic links. Stowaway creates and
removes these links for you, so you rarely need to edit them by hand. Each
one also holds an empty `.keep` file, because git doesn't track empty
directories. Stowaway reads only the links, so it ignores `.keep`.

## An example

Let's set up a laptop that uses git and a few zsh settings. First, create a
module for each tool.

```sh
./stowaway module create git
./stowaway module create zsh
```

Then group them into a role, and add the role to a host.

```sh
./stowaway role create base
./stowaway role add base --module git --module zsh

./stowaway host create laptop
./stowaway host add laptop --role base
```

You can check the result with `show`.

```
$ ./stowaway show laptop
Active

laptop
└── base/
    ├── git
    └── zsh

Modules: git, zsh

Available

Hosts:   laptop
Roles:   base
Modules: git, zsh
```

Finally, apply the host. `switch` links each module's files into your home
directory, runs its install script, and records the host so that new shells
load the same modules.

```sh
./stowaway switch laptop
```

Open a new terminal to load the configuration. If you want to see what
`switch` would change first, run it with `--dry-run`.

The first `switch` links `.zshenv`, `.zprofile` and `.zshrc` into your home
directory. If you already have any of these files, Stow reports a conflict
and changes nothing. In that case, move your existing files aside and copy
what you want to keep into a module.

When you leave out the host name, `host create` uses this machine's name
(its LocalHostName, from Sharing settings). `show`, `switch`, `host add` and
`host remove` use the host you applied last, or this machine's name before
the first switch. `host delete` always needs a name.

## Writing a module

`module create` gives each module a starting set of files. Each one has a
comment explaining when it runs.

```
modules/git/
├── .stow-local-ignore -> ../../.stow-ignore
├── env.zsh
├── profile.zsh
├── rc.zsh
├── install.zsh
└── uninstall.zsh
```

- **`env.zsh`** - sourced by every zsh, including scripts. Use it for
  variables other programs need, such as `EDITOR`.
- **`profile.zsh`** - sourced by login shells, such as a new terminal window
  or an ssh session. Use it for additions to `PATH`. On macOS,
  `/etc/zprofile` rebuilds `PATH` after `env.zsh` runs and moves earlier
  additions behind the system directories, so a directory added in
  `env.zsh` loses to `/usr/bin`.
- **`rc.zsh`** - sourced by interactive shells. Use it for aliases,
  functions, the prompt and key bindings.
- **`install.zsh`** - run by every `switch`. It should install the tool if
  it's missing and do nothing if it's already in place. It runs without
  your shell's startup files, but the XDG variables such as
  `XDG_DATA_HOME` are set.
- **`uninstall.zsh`** - run by `switch` once the host no longer uses the
  module. It should remove what `install.zsh` installed. A `switch` runs
  uninstall scripts before install scripts.

Delete any of these files your module doesn't need.

Modules are independent of each other. They load, install and uninstall in
alphabetical order, and Stowaway doesn't provide a way to change that order.
A module therefore shouldn't depend on another module's files having loaded
or its install script having run. For example, an install script that needs
Homebrew can't rely on a `homebrew` module's `env.zsh` to put `brew` on
`PATH`. It can call `brew` by its full path, or check that `brew` exists and
fail with a message. If your setup needs a fixed order, build it into your
own modules.

### Linking files into your home directory

Files and directories whose names start with `dot-` are linked into your
home directory, with `dot-` replaced by a dot. For example, git's
configuration can live in the module like this:

```
modules/git/dot-config/git/config  ->  ~/.config/git/config
```

Everything else in the module, including the scripts above, stays in the
repository. The shared rules in `.stow-ignore` decide this, and you can add
your own patterns there.

Edits to a linked file take effect right away, since the file in your home
directory is a link to the one in the repository. Similarly, new shells read
the host's links each time they start, so changes to a role or to a
module's `.zsh` files apply in the next shell. Run `switch` again when you
add or remove modules, or add new `dot-` files.

## Commands

```
stowaway show [HOST]       Show a host's roles and modules, and what's available
stowaway switch [HOST]     Apply a host's configuration

stowaway host create       Create a host
stowaway host add          Add roles and modules to a host
stowaway host remove       Remove roles and modules from a host
stowaway host delete       Delete a host

stowaway role create       Create a role
stowaway role add          Add roles and modules to a role
stowaway role remove       Remove roles and modules from a role
stowaway role delete       Delete a role

stowaway module create     Create a module
stowaway module delete     Delete a module
```

Every command accepts `--help`, and `./stowaway help <command>` prints the
same text.

## What Stowaway changes

Stowaway keeps its effects on your system small and predictable. A `switch`
changes only the following:

- links to `.zshenv`, `.zprofile` and `.zshrc` in your home directory, which
  load the host's modules
- links to each module's `dot-` files
- a link at `~/.config/stowaway/host` to the applied host
- a list of installed modules at `~/.local/state/stowaway/installed`, which
  lets the next `switch` uninstall modules you've removed

Anything else is up to your modules' install scripts.

## License

Stowaway is licensed under the [Apache License, Version 2.0](LICENSE).

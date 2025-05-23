# TSM - Tmux Session Manager

A minimal tmux session manager that helps you efficiently manage your tmux sessions.

## Features

- List all unique session names
- Kill all sessions with a given base name
- Create and manage floating popup sessions

## Installation

### Manual Installation

Clone the repository and copy the script to a directory in your PATH:

```bash
git clone https://github.com/Yukaii/tsm.git
cd tsm
chmod +x tsm
cp tsm /usr/local/bin/
```

### Using bpkg

You can install tsm using [bpkg](https://github.com/bpkg/bpkg):

```bash
bpkg install Yukaii/tsm -g
```

## Usage

```
Usage: tsm <command> [options]

Tmux Session Manager (tsm) - Manage tmux sessions efficiently

Commands:
  list                List all unique session names
  kill <session>      Kill all sessions with the given base name
  popup [command]     Create or attach to a floating popup session
  help [command]      Display help information for tsm or a specific command

Use "tsm help <command>" for more information about a specific command.
```

### Examples

List all sessions:
```bash
tsm list
```

Kill a session:
```bash
tsm kill mysession
```

Create a floating popup session:
```bash
tsm popup
```

Open vim in a floating popup session:
```bash
tsm popup "vim myfile.txt"
```

## Requirements

- tmux

## License

MIT
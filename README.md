# NAME

bak - easy archive management using YAML specifications

# SUBCOMMANDS

* up: update archive from saved sources
* down: send archive files "down" to their destinations
* rm: delete an archive or file in the archive
* new: create an archive or insert a file into an existing archive
* ls: show the files present in an archive
* edit: use editor to open an archive specification for manual editing

# OPTIONS

* -h|--help
* -v|--version
* -V|--verbose
* --fake
* -f|--up-file=s
* -F|--down-file=s
* -m|--up-method=s
* -M|--down-method=s
* -r|--registry=s
* -a|--archive=s

# EXAMPLES

bak new dotfiles

bak add dotfiles.vim ~/.vimrc

bak add dotfiles.bash ~/.bashrc

bak up dotfiles

bak down dotfiles.bash

# LICENSE

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.

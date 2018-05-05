# Name

    bak - easy archive management using YAML specifications

# Synopsis

`bak` is like `tar`, but its interface is simpler. in the background,
`bak` relies on YAML files to describe what an archive is. here is an
example archive definition:

    ---
    _root: ~/.config/nvim
    plugin:
      up_file: plugins.vim
      up_method: COPY
      down_file: plugins.vim
      down_method: COPY
    init:
      up_file: init.vim
      down_file: init.vim
    ...

# Install

run the following commands:

```shell
perl Build.PL
./Build
./Build test
./Build install
```

# Subcommands

- up

    update archive from saved sources

- down

    send archive files "down" to their destinations

- rm

    delete an archive or file in the archive

- new

    create an archive or insert a file into an existing archive

- ls

    show the files present in an archive

- edit

    use editor to open an archive specification for manual editing

# Options

- -h|--help

    print a help message covering options and subcommands

- -v|--version

    print App::Util::Bak version

- -V|--verbose

    print additional information

- --fake

    rather than making changes to any files, show which files would be changed

- -f|--up-file=s

    set the file used as the source by the up subcommand

- -F|--down-file=s

    set the file used as the destination by the down subcommand

- -m|--up-method=s

    set the method for getting a file up into an archive. accepted values
    are COPY and MOVE.

- -M|--down-method=s

    set the method for sending a file down from an archive. accepted
    values are COPY, MOVE, and LINK.

- -r|--registry=s

    set the file used as the specification of the archive

- -a|--archive=s

    set the file or directory used as the destination of `up` or the source
    of `down`

# Examples

bak new dotfiles

bak new dotfiles.vim ~/.vimrc

bak new dotfiles.bash ~/.bashrc

bak up dotfiles

bak down dotfiles.bash

# License

Copyright (C) 2018 Adam Marshall.

This software is available under the MIT License.

# Ubuntu Desktop Setup (UDS)

## :page_with_curl: About

A simple setup script to

1. configure the desktop theme and style;
2. place miscellaneous other configuration files.

UDS configures [_Ubuntu_ 23.10 _Mantic Minotaur_][ubuntu-23.10] by installing various packages and placing (new) configuration files. The desktop environment used is [_Regolith Linux_ 3][regolith], which combines the [GNOME] desktop environment and [i3]. The theme UDS employs is [`sainnhe/gruvbox-material`](https://github.com/sainnhe/gruvbox-material), a modified version of [`morhetz/gruvbox`](https://github.com/morhetz/gruvbox).

![Desktop](files/.show-off/desktop.gif)

The script will

1. (optionally) completely remove `snapd`;
2. (for the next step) setup Personal Package Archives (PPAs);
3. install basic packages;
4. place appropriate configuration files.

[ubuntu-23.10]: https://releases.ubuntu.com/23.10/
[regolith]: https://regolith-desktop.com/
[GNOME]: https://www.gnome.org/
[i3]: https://i3wm.org/

## :rocket: Usage

We assume Ubuntu Desktop has already been installed - there are no special requirements or dependencies, the minimal version of the desktop suffices. The installation script can be downloaded and executed in the terminal. After downloading the script, you may optionally enable the `purge_snapd` function by uncommenting it in the `main` function at the very bottom.

```console
$ wget https://raw.githubusercontent.com/georglauterbach/uds/main/setup.sh
$ bash ./setup.sh
...

$ reboot
$ regolith-look set gruvbox-material
```

## :mega: Supplementary Projects

You might want to have a look at these awesome projects as well:

- [`junegunn/fzf`](https://github.com/junegunn/fzf) - a general-purpose command-line fuzzy finder
- [`akinomyoga/ble.sh`](https://github.com/akinomyoga/ble.sh) - command line editor written in pure Bash which replaces the default GNU Readline
- [`volian/nala`](https://gitlab.com/volian/nala) - front-end for `libapt-pkg`

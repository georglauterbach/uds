# Ubuntu Desktop Setup (UDS)

## :page_with_curl: About

A simple setup script to configure the desktop theme and style & setup miscellaneous configuration files. UDS configures [_Ubuntu_ 22.04 _Jammy Jellyfish_][ubuntu-22.04]. It installs various packages and places (new) configuration files. The desktop theme is based upon [_Regolith Linux_ 2][regolith-github], which combines the [GNOME] desktop environment and [i3].

![Desktop](files/images/desktop.png)

The script will

1. (optionally) completely remove `snapd`;
2. (for the next step) setup Personal Package Archives (PPAs);
3. install basic packages;
4. place appropriate configuration files.

[ubuntu-22.04]: https://releases.ubuntu.com/22.04/
[regolith-github]: https://github.com/regolith-linux/
[GNOME]: https://www.gnome.org/
[i3]: https://i3wm.org/

## :rocket: Usage

We assume Ubuntu has already been installed - there are no special requirements or dependencies. The installation script can be downloaded and executed in the terminal. After downloading the script, you may optionally enable the `purge_snapd` function by uncommenting it in the `main` function at the very bottom.

```console
$ wget https://raw.githubusercontent.com/georglauterbach/uds/main/setup.sh
$ bash ./setup.sh
...

$ reboot
$ regolith-look set gruvbox
```

## :mega: Supplementary Projects

You might want to have a look at these awesome projects as well:

- [`junegunn/fzf`](https://github.com/junegunn/fzf) - a general-purpose command-line fuzzy finder
- [`akinomyoga/ble.sh`](https://github.com/akinomyoga/ble.sh) - command line editor written in pure Bash which replaces the default GNU Readline
- [`volian/nala`](https://gitlab.com/volian/nala) - front-end for `libapt-pkg`
- [`sainnhe/gruvbox-material`](https://github.com/sainnhe/gruvbox-material) - modified version of [Gruvbox](https://github.com/morhetz/gruvbox)

# Ubuntu Desktop Setup (UDS)

## About

_UDS_ is a Ubuntu \[GNU/Linux\] desktop setup application to

1. configure the desktop theme and style
2. setup miscellaneous configuration files

_UDS_ configures [Ubuntu 22.04 LTS]. It installs various packages and places (new) configuration files. The desktop theme is based upon [Regolith Linux] 2.0, which combines the [GNOME] desktop environment and [i3]\(-gaps\).

![Desktop](files/images/desktop.png)

## Usage

We assume Ubuntu has already been installed - there are no special requirements or dependencies other than the packages shown in the first command below. The installation script can be downloaded and executed in the terminal. The first command will clone the repository and acquire the binary for installation. Make sure to execute the first command in the directory you want _UDS_'s files to be placed in.

``` CONSOLE
$ wget https://raw.githubusercontent.com/georglauterbach/uds/dev/scripts/setup.sh
$ sudo --preserve-env=HOME,USER,LOG_LEVEL bash ./setup.sh
...

$ reboot # and choose Regolith as the new DE
$ regolith-look set gruvbox
```

## What _UDS_ Does

The `setup.sh` script does the following:

1. Complete removal of `snapd`
2. Setup of Personal Package Archives (PPAs)
3. Installation of packages
4. Placing configuration files

## Development

Fork the repository, and clone it by running the following command

``` CONSOLE
$ git clone --recurse-submodules https://github.com/<YOUR GIT ACCOUNT NAME>/uds.git
...
```

## Licensing

This project is licensed under the [GNU General Public License v3], except for those parts (lines of code from libraries used in this project) already licensed under other licenses.

[//]: # (Links)

[Ubuntu 22.04 LTS]: https://releases.ubuntu.com/22.04/
[Regolith Linux]: https://github.com/regolith-linux/
[GNOME]: https://www.gnome.org/
[i3]: https://i3wm.org/

[GNU General Public License v3]: https://www.gnu.org/licenses/gpl-3.0.txt

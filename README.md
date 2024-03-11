# Ubuntu Desktop Setup (UDS)

## :page_with_curl: About

UDS configures Ubuntu by installing various packages and placing (new) configuration files. UDS will (optionally) completely remove `snapd`, setup Personal Package Archives (PPAs), install basic packages, and place configuration files.

[image::hyperlink]: https://img.freepik.com/free-photo/natures-beauty-shines-multi-colored-floral-decoration-generative-ai_188544-8615.jpg?w=1800&t=st=1710173895~exp=1710174495~hmac=384bff9ad2e1aded5ac611f9bddc9539d40f8d5050dce67e23a648ccab6ee095
[image::referral]: https://www.freepik.com/free-photo/natures-beauty-shines-multi-colored-floral-decoration-generative-ai_40948330.htm#page=3&query=cool%20wallpaper&position=19&from_view=keyword&track=ais&uuid=5e656229-57f2-41c7-871d-2fef44a20e21

| Property            | UDS' Choice                                  |
| :------------------ | :------------------------------------------- |
| Linux distribution  | [Ubuntu Desktop 23.10][ubuntu-23.10::web]    |
| Desktop environment | [Regolith Linux 3.0][regolith::web]          |
| Theme               | [Gruvbox Material][gruvbox-material::github] |

[ubuntu-23.10::web]: https://releases.ubuntu.com/23.10/
[regolith::web]: https://regolith-desktop.com/
[gruvbox-material::github]: https://github.com/sainnhe/gruvbox-material

## :rocket: Usage

> [!IMPORTANT]
>
> We assume Ubuntu Desktop has already been installed - there are no special requirements or dependencies, the minimal version of the desktop suffices.

The installation script can be downloaded and executed in the terminal. After downloading the script, you may optionally enable the `purge_snapd` function by uncommenting it in the `main` function at the very bottom.

```console
$ wget https://raw.githubusercontent.com/georglauterbach/uds/main/setup.sh
$ bash setup.sh
...

$ reboot
```

## :mega: Supplementary Projects

You might want to take a look at the following outstanding projects.

### :star2: General

1. [`junegunn/fzf`](https://github.com/junegunn/fzf): general-purpose command-line fuzzy finder
2. [`akinomyoga/ble.sh`](https://github.com/akinomyoga/ble.sh): command line editor that replaces the default GNU Readline
3. [`volian/nala`](https://gitlab.com/volian/nala): frontend for `libapt-pkg`

### :crab: Written in Rust

> [!TIP]
>
> Check out [`cargo-bins/cargo-binstall`](https://github.com/cargo-bins/cargo-binstall) first. This way, you may be able to save yourself time by not requiring local compilation; use `cargo binstall` instead of `cargo install`.

1. [`mozilla/sccache`](https://github.com/mozilla/sccache): compiler wrapper that avoids compilation when possible
2. [`Canop/bacon`](https://github.com/Canop/bacon): background Rust code checker
3. [`zellij-org/zellij`](https://github.com/zellij-org/zellij): terminal workspace (multiplexer)
4. [`extrawurst/gitui`](https://github.com/extrawurst/gitui): blazing fast terminal-UI for git
5. [`casey/just`](https://github.com/casey/just): command runner

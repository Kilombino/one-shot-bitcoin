# One Shot Bitcoin

A Bitcoin (BLAKE2b) node with Lightning and DATUM mining, installed with one command. You see the exact version of every piece before it installs, and nothing updates until you say so.

[Español](README-ES.md)

> **Status: 0.2, beta.** On Linux, tested on Ubuntu with Docker: the install, the dashboards, update and rollback. Not yet run through a full chain sync, wallet creation or a real miner. The USB image builds and carries the right files but has not been booted yet; the Windows and macOS paths are written but not yet tried on a real Windows or Mac.

## What you get

| Piece | What it is | Made by |
|-------|-----------|---------|
| **Bitcoin Knots** | The node, on the BLAKE2b chain, with its dashboard | Bitcoin Knots, packaged by Horizon BTC / Léo Haf |
| **Lightning Fork** | LND for the BLAKE2b chain, with its dashboard | PaulsCode |
| **DATUM CONVOY** | Mining gateway: your miner works on your own block templates | DATUM, Convoy |
| Tor, I2P | Private connections for the node and Lightning | Tor Project, PurpleI2P |

One Shot Bitcoin adds no software of its own to your coins' path: it is a short script, a Docker Compose file and a list of versions that puts those pieces together.

## Three ways to install

| You have | Use |
|----------|-----|
| A computer just for the node | [The USB image](#a-computer-just-for-the-node-usb) |
| Linux with Docker | [Install on Linux](#install-on-linux) |
| Windows or a Mac | [Windows](#windows) · [macOS](#macos) |

## Install on Linux

You need a 64-bit Linux computer (x86 or ARM) with [Docker](https://docs.docker.com/engine/install/), and disk space: about 30 GB for a pruned node, hundreds of GB for a full one.

```sh
git clone https://github.com/Kilombino/one-shot-bitcoin.git
cd one-shot-bitcoin
./install.sh
```

The installer:

1. Shows the version of every piece it is about to install.
2. Asks where to keep the data.
3. Asks **pruned or full node**. Both verify every block; a pruned node then keeps only the latest ones.
4. Asks whether the dashboards answer only on this computer or on your home network too.
5. Asks you to confirm, then downloads and starts everything.

When it finishes it prints the addresses of the panel and the three dashboards. They share one user and password, generated on your computer: `./oneshot password`.

## A computer just for the node (USB)

The USB image is the official Ubuntu Server installer with One Shot Bitcoin on board. You answer what is yours to decide (language, keyboard, network, **which disk to erase**, your user and password); Docker and One Shot Bitcoin are set up for you.

Build the image on any Linux computer:

```sh
git clone https://github.com/Kilombino/one-shot-bitcoin.git
cd one-shot-bitcoin
usb/make-usb.sh            # builds usb/build/one-shot-bitcoin-usb.iso
usb/make-usb.sh /dev/sdX   # or build and write it to that pendrive (erases it)
```

The script downloads Ubuntu Server 24.04 from Ubuntu, verifies it against Ubuntu's signed checksums and adds one folder and one boot menu entry; nothing inside Ubuntu is changed. You can also write the `.iso` with balenaEtcher or Rufus.

Then:

1. Plug the computer into your router with a cable and boot it from the pendrive (64-bit PC; a 4 GB pendrive or bigger).
2. Choose **Install One Shot Bitcoin**. The installer asks you to confirm before it touches any disk.
3. When it finishes, remove the pendrive and log in. The first login offers to set the node up: the same questions as on Linux.
4. Open the panel from another computer on your network, at the address it prints.

## Windows

Windows runs the node in Docker Desktop, through WSL (the Linux that Windows ships).

1. In PowerShell as administrator: `wsl --install -d Ubuntu`. Restart and create your Linux user.
2. Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), start it, and turn on *Settings > Resources > WSL integration* for Ubuntu.
3. Download [`windows/install.ps1`](windows/install.ps1) and run it: `powershell -ExecutionPolicy Bypass -File install.ps1`. It checks the two steps above and starts the same installer as on Linux, inside WSL.

Later, the commands below work from the Ubuntu window, in `~/one-shot-bitcoin`. The node runs while Docker Desktop is open. For miners on your network to reach it, allow the Stratum port (23334) in Windows Firewall when it asks.

## macOS

1. Install [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) and start it. In *Settings > Resources*, raise the disk limit: 40 GB or more for a pruned node.
2. In Terminal:

```sh
git clone https://github.com/Kilombino/one-shot-bitcoin.git
cd one-shot-bitcoin
./install.sh
```

On a Mac the data is kept in Docker volumes (`oneshot_knots`, `oneshot_lnd` and others) instead of a folder, because a node on a shared Mac folder is many times slower. A pruned node is the sensible choice here. The node runs while Docker Desktop is open.

## First steps

1. **Wait for the node to sync.** From hours to days, depending on the computer and the connection. The Node dashboard shows the progress.
2. **Create your Lightning wallet.** Lightning starts once the node passes block 961640. Open its dashboard, choose *Setup a new node* and **write down the 24 words on paper**. They are the only backup of your coins.
3. **Mine.** Open the Mining dashboard, set the address you want to be paid to, and point your miner at the `stratum+tcp://` address the panel shows.

## You are in control

The versions you are running are written in `state/versions.env`. The versions on offer are in [`versions.env`](versions.env), each image pinned by its digest.

| Command | What it does |
|---------|--------------|
| `./oneshot status` | What is running, and which versions |
| `./oneshot check` | Looks for newer versions. Changes nothing |
| `./oneshot update` | Shows each change, from which version to which, and asks before applying it |
| `./oneshot rollback` | Goes back to the versions you had before the last update |
| `./oneshot stop` / `start` / `restart` | Stop or start everything, or one piece (`./oneshot restart lnd`) |
| `./oneshot logs knots` | What a piece is saying |
| `./oneshot password` | User and password of the dashboards |
| `./oneshot uninstall` | Removes the containers. Your data stays |

There is no automatic update and no telemetry. `check` and `update` do a `git pull` of this repository and compare two text files; you can read the difference yourself with `git log -p versions.env`.

To run a version of your own choosing, edit `state/versions.env` and run `./oneshot restart`.

Going back is not always possible: a database opened by a newer version may not open with an older one. Read the release notes of each piece before a big jump.

## Where things are

- **Your data**: the directory you chose (by default `~/oneshot-data`), one folder per piece; on macOS, Docker volumes named `oneshot_*`. `lnd` holds your Lightning wallet and channels: back it up, and never run two copies of it at once.
- **Your settings**: `state/config.env` (ports, passwords, prune size at install). The small files the containers read are generated in `state/files/`.
- **Ports opened to the network**: Bitcoin P2P (8333), Lightning P2P (9735) and Stratum (23334). The dashboards (8000 to 8003) and Lightning's gRPC and REST answer only on this computer unless you chose the home network.

The node's RPC is not published outside Docker. The prune size can be changed later in the Node dashboard's settings.

## Credits

All credit for the software goes to its authors: Bitcoin Knots, Horizon BTC and Léo Haf, PaulsCode, the DATUM and Convoy developers, Lightning Labs, the Tor Project and PurpleI2P. This repository only puts their work together.

## License

MIT, for the files in this repository. Each piece keeps its own license.

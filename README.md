# One Shot Bitcoin

A Bitcoin (BLAKE2b) node with Lightning and DATUM mining, installed with one command. You see the exact version of every piece before it installs, and nothing updates until you say so.

[Español](README-ES.md)

> **Status: 0.1, Linux.** Tested on Ubuntu with Docker: the install, the dashboards, update and rollback. Not yet run through a full chain sync, wallet creation or a real miner; treat it as a beta. A bootable USB image and Windows/macOS versions come next.

## What you get

| Piece | What it is | Made by |
|-------|-----------|---------|
| **Bitcoin Knots** | The node, on the BLAKE2b chain, with its dashboard | Bitcoin Knots, packaged by Horizon BTC / Léo Haf |
| **Lightning Fork** | LND for the BLAKE2b chain, with its dashboard | PaulsCode |
| **DATUM CONVOY** | Mining gateway: your miner works on your own block templates | DATUM, Convoy |
| Tor, I2P | Private connections for the node and Lightning | Tor Project, PurpleI2P |

One Shot Bitcoin adds no software of its own to your coins' path: it is a short script, a Docker Compose file and a list of versions that puts those pieces together.

## Install

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

- **Your data**: the directory you chose (by default `~/oneshot-data`), one folder per piece. `lnd/` holds your Lightning wallet and channels: back it up, and never run two copies of it at once.
- **Your settings**: `state/config.env` (ports, passwords, prune size at install).
- **Ports opened to the network**: Bitcoin P2P (8333), Lightning P2P (9735) and Stratum (23334). The dashboards (8000 to 8003) and Lightning's gRPC and REST answer only on this computer unless you chose the home network.

The node's RPC is not published outside Docker. The prune size can be changed later in the Node dashboard's settings.

## Credits

All credit for the software goes to its authors: Bitcoin Knots, Horizon BTC and Léo Haf, PaulsCode, the DATUM and Convoy developers, Lightning Labs, the Tor Project and PurpleI2P. This repository only puts their work together.

## License

MIT, for the files in this repository. Each piece keeps its own license.

#!/usr/bin/env bash
# One Shot Bitcoin: one command to get a Bitcoin (BLAKE2b) node with Lightning
# and DATUM mining. It shows what it will install and asks before doing it.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/oneshot" install

#!/bin/bash
set -euo pipefail

source buildByond.conf

wget -O ./librust_g.so "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ./librust_g.so
ldd ./librust_g.so

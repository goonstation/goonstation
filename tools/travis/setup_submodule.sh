#!/bin/bash
set -euo pipefail

# Encrypted SSH Deploy Key for goonstation-secret

openssl aes-256-cbc -K $encrypted_5f214af470e0_key -iv $encrypted_5f214af470e0_iv -in deploykey-secret.txt.enc -out deploykey-secret.txt -d
eval $(ssh-agent -s)
chmod 600 deploykey-secret.txt
ssh-add deploykey-secret.txt
git submodule update --init

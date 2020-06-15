#!/bin/bash
set -euo pipefail

# Encrypted SSH Deploy Key for goonstation-secret

openssl aes-256-cbc -K $encrypted_5f214af470e0_key -iv $encrypted_5f214af470e0_iv -in tools/travis/deploykey-secret.txt.enc -out tools/travis/deploykey-secret.txt -d
eval $(ssh-agent -s)
chmod 600 tools/travis/deploykey-secret.txt
ssh-add tools/travis/deploykey-secret.txt
git submodule update --init

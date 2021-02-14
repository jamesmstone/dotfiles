#!/usr/bin/env bash
set -euo pipefail

lpass show "id_rsa" --notes > ~/.ssh/id_rsa;
chmod 400 ~/.ssh/id_rsa;
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub;

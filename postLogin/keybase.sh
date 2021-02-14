#!/usr/bin/env bash
set -euo pipefail
source ~/.dockerfunc
lpass show "keybase paperkey" --notes | keybase oneshot -u jamesstone;

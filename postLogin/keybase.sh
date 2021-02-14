#!/usr/bin/env bash
set -euo pipefail

lpass show "keybase paperkey" --notes | keybase oneshot -u jamesstone;

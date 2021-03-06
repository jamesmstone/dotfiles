#!/usr/bin/env bash
set -euo pipefail
source ~/.dockerfunc
source ~/.functions
lpass show "keybase paperkey" --notes | keybase oneshot -u jamesstone;
lpass show keybase.io --pass |
    head -c -2 | # this is needed as lastpass adds two '\n' at the end of the password.
    keybase unlock --stdin;                                                               

pass-init

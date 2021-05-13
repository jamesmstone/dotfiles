#!/usr/bin/env bash
set -euo pipefail

eval make -f - index <<EOF &> /dev/null & disown
.PHONY: index gmail

all: gmail index

index: gmail
	mu index

gmail:
	mbsync gmail

EOF

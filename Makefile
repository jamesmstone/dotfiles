.PHONY: all bin dotfiles etc emacs mbsync test shellcheck ssh

all: dotfiles etc emacs mbsync

pass:
	git clone --depth 1 git@github.com:jamesmstone/.password-store.git ~/.password-store; \

emacs:
	$(SHELL) $(.SHELLFLAGS) "git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d; \
	git clone --depth 1 https://github.com/jamesmstone/.doom.d ~/.doom.d; \
	git -C ~/.doom.d remote set-url origin git@github.com:jamesmstone/.doom.d; \
	yes | ~/.emacs.d/bin/doom install; \
	sudo apk add alpine-sdk gcc cmake libtool; \
	mkdir -p \`find ~/.emacs.d/.local -type d -name 'vterm' -not -path '*evil*'\`/build && \
	cd \`find ~/.emacs.d/.local -type d -name 'vterm' -not -path '*evil*'\`/build && \
	cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..  && \
	make; \
	sudo apk del alpine-sdk gcc cmake libtool;" \

mbsync:
	mkdir -p ~/Maildir/gmail ~/Maildir/exchange; \
	mu init; \

org:
	git clone --depth 1 git@github.com:/jamesmstone/Org ~/Org; \

dotfiles: ssh
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name "etc" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \

ssh:
	# add dotfiles for .ssh
	mkdir -p $(HOME)/.ssh; \
	for file in $(shell find $(CURDIR)/.ssh -name "*" -type f); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/.ssh/$$f; \
	done; \

etc:
	# add aliases for periodic
	for file in $(shell find $(CURDIR)/etc -name "*" -type f); do \
		f=$$(echo $$file  | sed -n 's|^.*etc/||p'   ); \
		e=$$(dirname $$f); \
		sudo mkdir -p /etc/$$e; \
		sudo ln -sfn $$file /etc/$$f ; \
	done; \

test: shellcheck

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

shellcheck:
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh

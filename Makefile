.PHONY: all bin dotfiles etc emacs test shellcheck

all: dotfiles etc emacs pass

pass:
	git clone --depth 1 https://github.com/jamesmstone/.password-store ~/.password-store; \
	git -C ~/.doom.d remote set-url origin git@github.com:jamesmstone/.password-store.git; \

emacs:
	git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d; \
	git clone --depth 1 https://github.com/jamesmstone/.doom.d ~/.doom.d; \
	git -C ~/.doom.d remote set-url origin git@github.com:jamesmstone/.doom.d; \
	~/.emacs.d/bin/doom install; \
	yes | ~/.emacs.d/bin/doom install; \

dotfiles:
	# add aliases for dotfiles
	for file in $(shell find $(CURDIR) -name ".*" -not -name "etc" -not -name ".gitignore" -not -name ".travis.yml" -not -name ".git" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
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

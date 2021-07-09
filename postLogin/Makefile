.PHONY: pgp ssh .password-store Org email gmail outlook exchange dockerhub dockertradsgitlab .clean

all: lastpass pgp ssh .password-store Org dockerhub dockertradsgitlab
# email gmail outlook exchange


# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

user = jamesmstone
domain = hotmail.com
email = $(user)@$(domain)

lpass = docker run --rm -i -v "${HOME}/.lpass:/root/.lpass" ${DOCKER_REPO_PREFIX}/lpass
lpassTTY = docker run --rm -it -v "${HOME}/.lpass:/root/.lpass" ${DOCKER_REPO_PREFIX}/lpass

lastpass:
	$(lpassTTY) login --plaintext-key --force "$(email)";
	touch lastpass

clean-lastpass:
	$(lpass) logout -f
	rm -f lastpass

keybase: lastpass
	$(lpass) show "keybase paperkey" --notes | keybase oneshot -u jamesstone; \
	$(lpass) show keybase.io --pass | \
	head -c -2 | \
	keybase unlock --stdin;
	touch keybase

clean-keybase:
	keybase logout
	rm -f keybase

pgp: keybase
	keyid = keybase pgp list | awk '/Keybase Key ID:/ {print $4}'
	keybase pgp export --unencrypted -s -q "${keyid}" | gpg --import --allow-secret-key-import;
	echo -e "5\ny\n" | gpg --command-fd 0 --edit-key DFB2A9423C974E94 trust

ssh: lastpass
	$(lpass) show "id_rsa" --notes > ${HOME}/.ssh/id_rsa;
	chmod 400 ${HOME}/.ssh/id_rsa;
	ssh-keygen -y -f ${HOME}/.ssh/id_rsa > ${HOME}/.ssh/id_rsa.pub;

clean-ssh:
	rm -rf "${HOME}/.ssh/id_rsa"

Org .password-store: ssh pgp
	git clone --depth 1 "git@github.com:jamesmstone/$@" "${HOME}/$@";

clean-Org clean-.password-store:
	rm -rf "${HOME}/$@"

dockerhub: .password-store
	pass show docker.com | \
		awk '/password/{print $$2}' | \
		docker login --password-stdin -u $$(pass show docker.com | awk '/username/{print $$2}')

clean-dockerhub:
	docker logout

dockertradsgitlab: .password-store
	pass show gitlab.traditionasia.com-token | docker login --password-stdin --username $$(pass show gitlab.tradition-private | awk '/username/{print $$2}') gitlab-registry.traditionasia.com

clean-dockertradsgitlab:
	docker logout gitlab-registry.traditionasia.com

email: gmail outlook exchange
	mu index

exchange outlook gmail: .password-store
	mbsync $@


clean: clean-lastpass clean-keybase clean-Org clean-.password-store clean-ssh clean-dockertradsgitlab clean-dockerhub

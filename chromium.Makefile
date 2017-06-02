# Reminder: Don't put secrets in this file.

######## Tools ########

.PHONY: cr-tools
cr-tools: cr-depot_tools cr-goma

.PHONY: cr-depot_tools
cr-depot_tools: ${HOME}/Code/depot_tools
${HOME}/Code/depot_tools:
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $@

.PHONY: cr-goma
cr-goma: ${HOME}/goma
${HOME}/goma:
	mkdir ${HOME}/goma && \
		cd ${HOME}/goma && \
		curl https://clients5.google.com/cxx-compiler-service/download/goma_ctl.py -o goma_ctl.py && \
		python goma_ctl.py update

######## Authentication ########

.PHONY: boto
boto: ${HOME}/.boto
${HOME}/.boto:
	download_from_google_storage --config

.PHONY: gitcookies
gitcookies: ${HOME}/.gitcookies
${HOME}/.gitcookies:
	@echo "Authenticate using @chromium.org: https://chromium-review.googlesource.com/new-password"
	@echo "Authenticate using @google.com: https://www.googlesource.com/new-password"
	@echo "Use Ctrl-Z to pause, enter cookies using bash, then resume and press Enter"
	@read

.PHONY: glogin
glogin:
	glogin

######## Building ########

.PHONY: cr-chromium
cr-chromium: cr-tools boto gitcookies ${HOME}/chromium
${HOME}/chromium:
	mkdir $@
	cd $@ && fetch chromium

.PHONY: cr-alt
cr-alt: cr-chromium ${HOME}/alt
${HOME}/alt:
	gclient-new-workdir.py ${HOME}/chromium $@

.PHONY: cr-bling
cr-bling: cr-tools boto gitcookies glogin ${HOME}/bling
${HOME}/bling:
	mkdir $@
	cd $@ && fetch ios_internal --target_os_only=True

.PHONY: cr-clank
cr-clank: cr-tools boto gitcookies ${HOME}/clank
${HOME}/clank:
	mkdir $@
	cd $@ && gclient config --name src/clank \
		https://chrome-internal.googlesource.com/clank/internal/apps.git\
		--deps-file=DEPS
	cd $@ && gclient sync --nohooks
	cd $@ && cd src && git config remote.origin.pushurl "https://chrome-internal-review.googlesource.com/clank/internal/apps.git"
	cd $@ && cd src/build && sudo ./install-build-deps-android.sh
	cd $@ && cd src/build && sudo ./install-build-deps.sh

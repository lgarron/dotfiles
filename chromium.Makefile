# Reminder: Don't put secrets in this file.

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

.PHONY: cr-tools
cr-tools: cr-depot_tools cr-goma

.PHONY: cr-chromium
cr-chromium: cr-tools ${HOME}/chromium
${HOME}/chromium:
	download_from_google_storage --config
	mkdir ${HOME}/chromium && \
		cd ${HOME}/chromium && \
		fetch chromium

.PHONY: cr-bling
cr-bling: cr-tools ${HOME}/bling
${HOME}/bling:
	@echo "Authenticate to googlesource.com for both @google.com and @chromium.org; see go/bling"
	@echo "Press Enter to continue"
	@read
	glogin
	mkdir ${HOME}/bling && \
		cd ${HOME}/bling && \
		fetch ios_internal --target_os_only=True

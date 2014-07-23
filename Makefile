#
# Copyright (c) 2014, Joyent, Inc. All rights reserved.
#

NAME=sdc-zookeeper

# Files
SMF_MANIFESTS_IN=zookeeper-base/smf/manifests/zookeeper.xml.in

include ./tools/mk/Makefile.defs
include ./tools/mk/Makefile.smf.defs

RELEASE_TARBALL=$(NAME)-pkg-$(STAMP).tar.bz2
ROOT := $(shell pwd)
RELSTAGEDIR := /tmp/$(STAMP)

#
# Targets
#

.PHONY: all

all: $(SMF_MANIFESTS) | sdc-scripts

.PHONY: release
release: all
	@echo "Building $(RELEASE_TARBALL)"
	@mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -r $(ROOT)/deps/sdc-scripts/* \
		$(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -r $(ROOT)/zookeeper-base/boot/* \
		$(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -r $(ROOT)/boot/* \
		$(RELSTAGEDIR)/root/opt/smartdc/boot
	@mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/zookeeper
	cp -r $(ROOT)/zookeeper-base/sapi_manifests \
		$(RELSTAGEDIR)/root/opt/smartdc/zookeeper
	cp -r $(ROOT)/zookeeper-base/smf \
		$(RELSTAGEDIR)/root/opt/smartdc/zookeeper
	(cd $(RELSTAGEDIR) && $(TAR) -jcf $(ROOT)/$(RELEASE_TARBALL) root)
	@rm -rf $(RELSTAGEDIR)

.PHONY: publish
publish: release
	@if [[ -z "$(BITS_DIR)" ]]; then \
		@echo "error: 'BITS_DIR' must be set for 'publish' target"; \
		exit 1; \
	fi
	mkdir -p $(BITS_DIR)/$(NAME)
	cp $(ROOT)/$(RELEASE_TARBALL) $(BITS_DIR)/$(NAME)/$(RELEASE_TARBALL)


include ./tools/mk/Makefile.deps
include ./tools/mk/Makefile.smf.targ
include ./tools/mk/Makefile.targ

sdc-scripts: deps/sdc-scripts/.git

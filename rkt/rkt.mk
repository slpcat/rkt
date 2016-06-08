LOCAL_NAME := $(patsubst %.mk,%,$(MK_FILENAME))

$(call setup-stamp-file,RKT_STAMP)

RKT_BINARY := $(BINDIR)/$(LOCAL_NAME)

# variables for makelib/build_go_bin.mk
BGB_STAMP := $(RKT_STAMP)
BGB_BINARY := $(RKT_BINARY)
BGB_PKG_IN_REPO := $(call go-pkg-from-dir)
BGB_GO_FLAGS := $(strip \
	-ldflags " \
		   $(RKT_STAGE1_DEFAULT_NAME_LDFLAGS) \
		   $(RKT_STAGE1_DEFAULT_VERSION_LDFLAGS) \
		   $(RKT_STAGE1_DEFAULT_LOCATION_LDFLAGS) \
		   $(RKT_VERSION_LDFLAGS) \
		   $(RKT_FEATURES_LDFLAGS) \
		   $(RKT_STAGE1_DEFAULT_IMAGE_FILENAME_LDFLAGS) \
		   $(RKT_STAGE1_DEFAULT_IMAGES_DIRECTORY_LDFLAGS) \
		 " \
	$(RKT_TAGS))

CLEAN_FILES += $(BGB_BINARY)
TOPLEVEL_STAMPS += $(RKT_STAMP)

$(call generate-stamp-rule,$(RKT_STAMP))

$(BGB_BINARY): $(MK_PATH) | $(BINDIR)

include makelib/build_go_bin.mk

manpages: GO_ENV += GOARCH=$(GOARCH_FOR_BUILD) CC=$(CC_FOR_BUILD)
manpages: | $(GOPATH_TO_CREATE)/src/$(REPO_PATH)
	mkdir -p dist/manpages/
	ls rkt/*.go | grep -vE '_test.go|main.go|_gen.go' | $(GO_ENV) xargs "$(GO)" run rkt/manpages_gen.go

bash-completion: GO_ENV += GOARCH=$(GOARCH_FOR_BUILD) CC=$(CC_FOR_BUILD)
bash-completion: | $(GOPATH_TO_CREATE)/src/$(REPO_PATH)
	mkdir -p dist/bash_completion/
	ls rkt/*.go | grep -vE '_test.go|main.go|_gen.go' | $(GO_ENV) xargs "$(GO)" run rkt/bash_completion_gen.go

protobuf:
	scripts/genproto.sh

$(call undefine-namespaces,LOCAL)
# RKT_STAMP deliberately not cleared
# RKT_BINARY deliberately not cleared

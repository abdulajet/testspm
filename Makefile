XCODEBUILD := xcodebuild
BUILD_FLAGS = -scheme $(SCHEME)
TEST_FLAGS = -scheme $(TEST_SCHEME) -destination 'platform=iOS Simulator,name=iPhone 7'

SCHEME ?= NexmoClient
TEST_SCHEME ?= NexmoClientTests


MINIRTC_VERSION ?= 0.01.78
OCMOCK_VERSION ?= 3.4

OCMOCK_FOLDER ?= Frameworks/OCMock
OCMOCK_VERSION_FILE = $(OCMOCK_FOLDER)/version
CURRENT_OCMOCK_VERSION = $(shell cat $(OCMOCK_VERSION_FILE))

MINIRTC_FOLDER ?= Frameworks/MiniRTC
MINIRTC_VERSION_FILE = $(MINIRTC_FOLDER)/version
CURRENT_MINIRTC_VERSION = $(shell cat $(MINIRTC_VERSION_FILE))

build: build_debug build_release

deps: minirtc ocmock
	@echo
	@echo "Done syncing dependencies."

minirtc:
	@echo
	@echo "-----------------------------------"
	@echo "Syncing MiniRTC v$(MINIRTC_VERSION)"
	@echo "-----------------------------------"

ifneq ($(MINIRTC_VERSION),$(CURRENT_MINIRTC_VERSION))
	@echo "Wrong or non-existing MiniRTC version. Downloading v$(MINIRTC_VERSION) from Artifactory"
	@rm -rf $(MINIRTC_FOLDER)
	@mkdir -p $(MINIRTC_FOLDER)

	@curl -N -L -f -s --show-error https://artifactory.ess-dev.com/artifactory/gradle-dev-local/com/nexmo/ios/MiniRTC/$(MINIRTC_VERSION)/MiniRTC-$(MINIRTC_VERSION)-iOS-Release.zip -o minirtc.zip
	@unzip minirtc.zip -d $(MINIRTC_FOLDER)
	@echo "$(MINIRTC_VERSION)" > $(MINIRTC_VERSION_FILE)
	@rm minirtc.zip
else
	@echo "Already have current MiniRTC version"
endif

ocmock:
	@echo
	@echo "---------------------------------"
	@echo "Syncing OCMock v$(OCMOCK_VERSION)"
	@echo "---------------------------------"

ifneq ($(OCMOCK_VERSION),$(CURRENT_OCMOCK_VERSION))
	@echo "Wrong or non-existing OCMock version. Downloading v$(OCMOCK_VERSION) from Github"
	@rm -rf $(OCMOCK_FOLDER)
	@mkdir -p $(OCMOCK_FOLDER)

	@curl -N -L -f -s --show-error https://github.com/erikdoe/ocmock/releases/download/v$(OCMOCK_VERSION)/ocmock-$(OCMOCK_VERSION).dmg -o ocmock.dmg
	
	@hdiutil attach -readonly -mountpoint ./ocmock ocmock.dmg 
	@cp -Rv ./ocmock/* $(OCMOCK_FOLDER)
	@hdiutil detach -force ./ocmock
	@rm ocmock.dmg

	@echo "$(OCMOCK_VERSION)" > $(OCMOCK_VERSION_FILE)
else
	@echo "Already have current OCMock version"
endif

clean:
	$(XCODEBUILD) clean $(BUILD_FLAGS)

build_debug: deps
	$(XCODEBUILD) build $(BUILD_FLAGS) -configuration Debug

build_release: deps
	$(XCODEBUILD) build $(BUILD_FLAGS) -configuration Release

test: deps
	$(XCODEBUILD) test $(TEST_FLAGS)

deploy: build_release

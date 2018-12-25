XCODEBUILD := xcodebuild
BUILD_FLAGS_IOS = -scheme $(SCHEME) -sdk iphoneos 
BUILD_FLAGS_SIM = -scheme $(SCHEME) -sdk iphonesimulator

TEST_FLAGS = -scheme $(TEST_SCHEME) -destination 'platform=iOS Simulator,name=iPhone 7'

SCHEME ?= NexmoClient
TEST_SCHEME ?= NexmoClientTests


MINIRTC_VERSION ?= 0.01.82
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
	@echo
	@echo "--------"
	@echo "Cleaning"
	@echo "--------"
	$(XCODEBUILD) clean $(BUILD_FLAGS)

build_debug: deps
	@echo
	@echo "------------------------------"
	@echo "Building Debug Framework (iOS)"
	@echo "------------------------------"
	$(XCODEBUILD) build $(BUILD_FLAGS_IOS) -configuration Debug

	@echo
	@echo "------------------------------------"
	@echo "Building Debug Framework (Simulator)"
	@echo "------------------------------------"
	$(XCODEBUILD) build $(BUILD_FLAGS_SIM) -configuration Debug

	@echo
	@echo "------------------------"
	@echo "Merging Debug Frameworks"
	@echo "------------------------"
	@cd utils; ./create_fat_framework.sh Debug

build_release: deps
	@echo
	@echo "--------------------------------"
	@echo "Building Release Framework (iOS)"
	@echo "--------------------------------"
	$(XCODEBUILD) build $(BUILD_FLAGS) -configuration Release

	@echo
	@echo "--------------------------------------"
	@echo "Building Release Framework (Simulator)"
	@echo "--------------------------------------"
	$(XCODEBUILD) build $(BUILD_FLAGS_SIM) -configuration Release

	@echo
	@echo "--------------------------"
	@echo "Merging Release Frameworks"
	@echo "--------------------------"
	@cd utils; ./create_fat_framework.sh Release

test: deps
	@echo
	@echo "-------------"
	@echo "Running tests"
	@echo "-------------"
	$(XCODEBUILD) test $(TEST_FLAGS)

deploy_deps:
	@echo
	@echo "---------------------------"
	@echo "Running Deploy Dependencies"
	@echo "---------------------------"
	@cd utils; ./set_build_number.sh
	
deploy: clean deploy_deps build
	@echo
	@echo "---------"
	@echo "Deploying"
	@echo "---------"
	@cd utils ; ./publish_to_artifactory.sh
	@cd utils ; ./release_version.sh


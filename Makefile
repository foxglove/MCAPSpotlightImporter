.PHONY: build
build:
	# https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows
	# https://stackoverflow.com/questions/4969932/separate-build-directory-using-xcodebuild
	# https://forums.swift.org/t/swiftpm-with-git-lfs/42396/4
	GIT_LFS_SKIP_DOWNLOAD_ERRORS=1 \
	xcodebuild \
		-disableAutomaticPackageResolution \
		-clonedSourcePackagesDirPath .swiftpm-packages \
		-destination generic/platform=macOS \
		-scheme MCAPSpotlightImporter \
		SYMROOT=$(PWD)/build \
		-configuration Release \
		clean build
	lipo build/Release/MCAPSpotlightImporter.mdimporter/Contents/MacOS/MCAPSpotlightImporter -verify_arch arm64 x86_64
	cd build/Release && zip -r MCAPSpotlightImporter.mdimporter.zip MCAPSpotlightImporter.mdimporter
	cd build/Release && zip -r MCAPSpotlightImporter.mdimporter.dSYM.zip MCAPSpotlightImporter.mdimporter.dSYM

.PHONY: lint-ci
lint-ci:
	docker run -t --rm -v $(PWD):/work -w /work ghcr.io/realm/swiftlint:0.49.1

.PHONY: format-ci
format-ci:
	docker run -t --rm -v $(PWD):/work ghcr.io/nicklockwood/swiftformat:0.49.18 --lint /work

.PHONY: build
build:
	# https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows
	# https://stackoverflow.com/questions/4969932/separate-build-directory-using-xcodebuild
	xcodebuild -disableAutomaticPackageResolution -clonedSourcePackagesDirPath .swiftpm-packages -scheme MCAPSpotlightImporter SYMROOT=$(PWD)/build -configuration Release clean build

.PHONY: lint-ci
lint-ci:
	docker run -t --rm -v $(PWD):/work -w /work ghcr.io/realm/swiftlint:0.49.1

.PHONY: format-ci
format-ci:
	docker run -t --rm -v $(PWD):/work ghcr.io/nicklockwood/swiftformat:0.49.18 --lint /work

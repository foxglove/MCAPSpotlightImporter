# MCAPSpotlightImporter

MCAPSpotlightImporter is a macOS [Spotlight Importer](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/MDImporters/Concepts/WritingAnImp.html) for [MCAP](https://mcap.dev/) files. The importer gives Spotlight the ability to index MCAP files so the names of their topics, schemas, attachments, and metadata are visible and searchable in Finder and anywhere else that Spotlight is used.

This importer is included with the [Foxglove Studio](https://foxglove.dev/studio) desktop app for macOS.

<img width="300" alt="Finder Get Info window" src="https://user-images.githubusercontent.com/14237/199407465-9886f55d-dc75-48bc-8c0d-5b5392a33d34.png">
<img width="430" alt="Finder search" src="https://user-images.githubusercontent.com/14237/199407550-fc36c034-5541-41db-86a7-eade699fd09f.png">
<img width="500" alt="Finder search by topics and schemas" src="https://user-images.githubusercontent.com/14237/199407593-b32836c5-f6b2-4b78-bfb0-25c4168c5f85.png">
<img width="500" alt="Spotlight search" src="https://user-images.githubusercontent.com/14237/199407603-3adbedb6-adfa-4322-a7e8-ea7487eb055d.png">

## Development

### Releasing a new version

1. Update version numbers in [Config.xcconfig](./MCAPSpotlightImporter/Config.xcconfig).

1. Create a corresponding version tag, e.g. `v1.2.3`, and push the tag to GitHub. CI will automatically build and create a [draft release](https://github.com/foxglove/MCAPSpotlightImporter/releases) with the build products attached as release assets.

1. Manually edit the release notes and publish the release.

### Local testing

You can make a local build using Xcode, or by running `make build`. When using `make build`, the output is placed in `./build/Release`.

- To test the .mdimporter locally, copy it to ~/Library/Spotlight.

  - After each rebuild of the importer, once it has been copied to ~/Library/Spotlight, sometimes it is necessary to kill Spotlight-related processes, to ensure a cached version of the importer is not being used: `sudo killall mds mdworker mdworker_shared corespotlightd mdbulkimport`. `/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill` may also help.

  - Run `mdimport -L` to see whether the importer plugin has been loaded. Sometimes the output of this command does not update immediately.

- Run `mdimport -d2 -t path/to/file.mcap` to run the importer on a file. The first line of output indicates whether the importer was actually used by saying `Imported '...' of type '...' with plugIn '...'`. If it instead says `with no plugIn`, the importer was not correctly loaded. Imported attributes will be displayed as part of the output.

- To enable debug logging, run `sudo log config --subsystem dev.foxglove.studio.mcap-mdimporter --mode level:debug`.

- To view logs from the importer, run `log stream --level debug --predicate 'subsystem = "dev.foxglove.studio.mcap-mdimporter"'`.

See also: [Troubleshooting Spotlight Importers](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/MDImporters/Concepts/Troubleshooting.html#//apple_ref/doc/uid/TP40001690-CJBEJBHH)

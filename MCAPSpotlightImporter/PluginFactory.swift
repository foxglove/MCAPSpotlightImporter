import Foundation

@objc public final class PluginFactory: NSObject {
  @objc public static func createPlugin(ofType type: CFUUID, factoryUUID: CFUUID) -> UnsafeMutableRawPointer? {
    if UUID(type) == kMDImporterTypeID {
      return UnsafeMutableRawPointer(ImporterPlugin.allocate(factoryUUID: factoryUUID).wrapperPtr)
    }
    return nil
  }
}

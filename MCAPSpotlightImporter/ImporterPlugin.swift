import Foundation
import OSLog
import CoreServices

fileprivate let log = Logger(subsystem: "dev.foxglove.studio.mcap-mdimporter", category: "ImporterPlugin")

final class ImporterPlugin {
  typealias VTable = MDImporterURLInterfaceStruct
  typealias Wrapper = (vtablePtr: UnsafeMutablePointer<VTable>, instance: UnsafeMutableRawPointer)
  let wrapperPtr: UnsafeMutablePointer<Wrapper>
  var refCount = 1
  let factoryUUID: CFUUID

  private init(wrapperPtr: UnsafeMutablePointer<Wrapper>, factoryUUID: CFUUID) {
    log.debug("ImporterPlugin.init factory=\(UUID(factoryUUID))")
    self.wrapperPtr = wrapperPtr
    self.factoryUUID = factoryUUID
    CFPlugInAddInstanceForFactory(factoryUUID)
  }

  deinit {
    let uuid = UUID(factoryUUID)
    log.debug("ImporterPlugin.deinit factory=\(uuid)")
    CFPlugInRemoveInstanceForFactory(factoryUUID)
  }

  static func fromWrapper(_ plugin: UnsafeMutableRawPointer?) -> Self? {
    if let wrapper = plugin?.assumingMemoryBound(to: Wrapper.self) {
      return Unmanaged<Self>.fromOpaque(wrapper.pointee.instance).takeUnretainedValue()
    }
    return nil
  }

  func queryInterface(uuid: UUID) -> UnsafeMutablePointer<Wrapper>? {
    if uuid == kMDImporterURLInterfaceID || uuid == IUnknownUUID {
      log.debug("ImporterPlugin.queryInterface for \(uuid): success")
      addRef()
      return wrapperPtr
    }
    log.debug("ImporterPlugin.queryInterface for \(uuid): unsupported")
    return nil
  }

  func addRef() {
    let newRefCount = refCount + 1
    log.debug("ImporterPlugin.addRef => \(newRefCount)")
    precondition(refCount > 0)
    refCount += 1
  }

  func release() {
    let newRefCount = refCount - 1
    log.debug("ImporterPlugin.release => \(newRefCount)")
    precondition(refCount > 0)
    refCount -= 1
    if refCount == 0 {
      Unmanaged<ImporterPlugin>.fromOpaque(wrapperPtr.pointee.instance).release()
      wrapperPtr.pointee.vtablePtr.deinitialize(count: 1)
      wrapperPtr.pointee.vtablePtr.deallocate()
      wrapperPtr.deinitialize(count: 1)
      wrapperPtr.deallocate()
    }
  }

  static func allocate(factoryUUID: CFUUID) -> Self {
    log.debug("ImporterPlugin.allocate factory=\(UUID(factoryUUID))")
    let wrapperPtr = UnsafeMutablePointer<Wrapper>.allocate(capacity: 1)
    let vtablePtr = UnsafeMutablePointer<VTable>.allocate(capacity: 1)

    let instance = Self(wrapperPtr: wrapperPtr, factoryUUID: factoryUUID)
    let unmanaged = Unmanaged.passRetained(instance)

    vtablePtr.initialize(to: VTable(
      _reserved: nil,
      QueryInterface: { wrapper, iid, outInterface in
        if let instance = ImporterPlugin.fromWrapper(wrapper) {
          if let interface = instance.queryInterface(uuid: UUID(iid)) {
            outInterface?.pointee = UnsafeMutableRawPointer(interface)
            return S_OK
          }
        }
        outInterface?.pointee = nil
        return HRESULT(bitPattern: 0x80000004) // E_NOINTERFACE <https://github.com/apple/swift/issues/61851>
      },
      AddRef: { wrapper in
        if let instance = ImporterPlugin.fromWrapper(wrapper) {
          instance.addRef()
        }
        return 0 // optional
      },
      Release: { wrapper in
        if let instance = ImporterPlugin.fromWrapper(wrapper) {
          instance.release()
        }
        return 0 // optional
      },
      ImporterImportURLData: { wrapper, mutableAttributes, contentTypeUTI, url in
        // Note: in practice, `wrapper` has the wrong value passed to it, so we can't use it here
        guard let contentTypeUTI = contentTypeUTI as String?,
              let url = url as URL?,
              let mutableAttributes = mutableAttributes as NSMutableDictionary?
        else {
          return false
        }

        var attributes: [AnyHashable: Any] = mutableAttributes as NSDictionary as Dictionary
        let result = importMCAPAttributes(&attributes, forFileAt: url, contentTypeUTI: contentTypeUTI)
        mutableAttributes.removeAllObjects()
        mutableAttributes.addEntries(from: attributes)
        return DarwinBoolean(result)
      }
    ))
    wrapperPtr.initialize(to: (vtablePtr: vtablePtr, instance: unmanaged.toOpaque()))
    return instance
  }
}

import Foundation
import MCAP
import OSLog
import UniformTypeIdentifiers

private let log = Logger(subsystem: "dev.foxglove.studio.mcap-mdimporter", category: "importMCAPAttributes")

/** Attributes declared in schema.xml */
enum SchemaAttributes: String {
  case topics = "dev_foxglove_mcap_mcap_topics"
  case schemas = "dev_foxglove_mcap_mcap_schemas"
}

extension UTType {
  static let mcap = UTType(importedAs: "dev.mcap.mcap", conformingTo: .data)
  static let foxgloveMCAP = UTType(importedAs: "dev.foxglove.mcap", conformingTo: .data)
}

extension FileHandle: IRandomAccessReadable {
  public func size() -> UInt64 {
    (try? seekToEnd()) ?? 0
  }

  public func read(offset: UInt64, length: UInt64) -> Data? {
    do {
      try seek(toOffset: offset)
      return try read(upToCount: Int(length))
    } catch {
      return nil
    }
  }
}

func importMCAPAttributes(_ attributes: inout [AnyHashable: Any], forFileAt url: URL, contentTypeUTI: String) -> Bool {
  guard contentTypeUTI == UTType.mcap.identifier || contentTypeUTI == UTType.foxgloveMCAP.identifier else {
    log.info("skipping importAttributes for url=\(url) contentTypeUTI=\(contentTypeUTI)")
    return false
  }

  let handle: FileHandle
  do {
    let decompressHandlers: DecompressHandlers = [:]
    handle = try FileHandle(forReadingFrom: url)
    let reader = try MCAPRandomAccessReader(handle, decompressHandlers: decompressHandlers)
    let uniqueTopics = Set(reader.channelsById.values.lazy.map(\.topic))
    let uniqueSchemas = Set(reader.schemasById.values.lazy.map(\.name))
    attributes[SchemaAttributes.topics.rawValue] = Array(uniqueTopics)
    attributes[SchemaAttributes.schemas.rawValue] = Array(uniqueSchemas)
    log.info("successful import of \(url), \(uniqueTopics.count) topics, \(uniqueSchemas.count) schemas")
    return true
  } catch let err {
    log.error("failed to import \(url): \(err.localizedDescription) (\(String(describing: err))")
    return false
  }
}

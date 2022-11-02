#import <CoreFoundation/CoreFoundation.h>

#import "MCAPSpotlightImporter-Swift.h"

#define PLUGIN_FACTORY_ID "675EC679-0E71-4A8C-8A00-7F01C7412BA5"

void *MCAPImporterPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeID) {
  return [PluginFactory createPluginOfType:typeID factoryUUID:CFUUIDCreateFromString(NULL, CFSTR(PLUGIN_FACTORY_ID))];
}


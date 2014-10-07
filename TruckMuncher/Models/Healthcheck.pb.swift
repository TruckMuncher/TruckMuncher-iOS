// Generated by the protocol buffer compiler.  DO NOT EDIT!

import Foundation
import ProtocolBuffers

private class HealthcheckRoot {
var extensionRegistry:ExtensionRegistry

init() {
extensionRegistry = ExtensionRegistry()
registerAllExtensions(extensionRegistry)
}
func registerAllExtensions(registry:ExtensionRegistry) {
}
}

func == (lhs: HealthResponse.Check, rhs: HealthResponse.Check) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  fieldCheck = fieldCheck && (lhs.hasKey == rhs.hasKey) && (!lhs.hasKey || lhs.key == rhs.key)
  fieldCheck = fieldCheck && (lhs.hasValue == rhs.hasValue) && (!lhs.hasValue || lhs.value == rhs.value)
  return (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
}

func == (lhs: HealthResponse.ExternalService, rhs: HealthResponse.ExternalService) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  fieldCheck = fieldCheck && (lhs.hasKey == rhs.hasKey) && (!lhs.hasKey || lhs.key == rhs.key)
  fieldCheck = fieldCheck && (lhs.hasValue == rhs.hasValue) && (!lhs.hasValue || lhs.value == rhs.value)
  return (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
}

func == (lhs: HealthResponse, rhs: HealthResponse) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  fieldCheck = fieldCheck && (lhs.hasStatus == rhs.hasStatus) && (!lhs.hasStatus || lhs.status == rhs.status)
  fieldCheck = fieldCheck && (lhs.hasRevision == rhs.hasRevision) && (!lhs.hasRevision || lhs.revision == rhs.revision)
  fieldCheck = fieldCheck && (lhs.hasNonce == rhs.hasNonce) && (!lhs.hasNonce || lhs.nonce == rhs.nonce)
  fieldCheck = fieldCheck && (lhs.hasTimestamp == rhs.hasTimestamp) && (!lhs.hasTimestamp || lhs.timestamp == rhs.timestamp)
  fieldCheck = fieldCheck && (lhs.checks == rhs.checks)
  fieldCheck = fieldCheck && (lhs.hasExternalServicesStatus == rhs.hasExternalServicesStatus) && (!lhs.hasExternalServicesStatus || lhs.externalServicesStatus == rhs.externalServicesStatus)
  fieldCheck = fieldCheck && (lhs.externalServices == rhs.externalServices)
  return (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
}

func == (lhs: HealthRequest, rhs: HealthRequest) -> Bool {
  if (lhs === rhs) {
    return true
  }
  var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
  return (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
}

final class HealthResponse : GeneratedMessage {


  //Nested type declaration start 

    final class Check : GeneratedMessage {
      private(set) var hasKey:Bool = false
      private(set) var key:String = ""

      private(set) var value:HealthResponse.Status = HealthResponse.Status.Ok
      private(set) var hasValue:Bool = false
      required init() {
           super.init()
      }
      override func isInitialized() -> Bool {
        if !hasKey {
          return false
        }
        if !hasValue {
          return false
        }
       return true
      }
      override func writeToCodedOutputStream(output:CodedOutputStream) {
        if hasKey {
          output.writeString(1, value:key)
        }
        if hasValue {
          output.writeEnum(2, value:value.toRaw())
        }
        unknownFields.writeToCodedOutputStream(output)
      }
      override func serializedSize() -> Int32 {
        var size:Int32 = memoizedSerializedSize
        if size != -1 {
         return size
        }

        size = 0
        if hasKey {
          size += WireFormat.computeStringSize(1, value:key)
        }
        if (hasValue) {
          size += WireFormat.computeEnumSize(2, value:value.toRaw())
        }
        size += unknownFields.serializedSize()
        memoizedSerializedSize = size
        return size
      }
      class func parseFromData(data:[Byte]) -> HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromData(data).build()
      }
      class func parseFromData(data:[Byte], extensionRegistry:ExtensionRegistry) -> HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
      }
      class func parseFromInputStream(input:NSInputStream) -> HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromInputStream(input).build()
      }
      class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) ->HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
      }
      class func parseFromCodedInputStream(input:CodedInputStream) -> HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromCodedInputStream(input).build()
      }
      class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponse.Check {
        return HealthResponse.Check.builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
      }
      class func builder() -> CheckBuilder {
        return CheckBuilder()
      }
      class func builderWithPrototype(prototype:Check) -> CheckBuilder {
        return Check.builder().mergeFrom(prototype)
      }
      func builder() -> CheckBuilder {
        return Check.builder()
      }
      func toBuilder() -> CheckBuilder {
        return Check.builderWithPrototype(self)
      }
      override func writeDescriptionTo(inout output:String, indent:String) {
        if hasKey {
          output += "\(indent) key: \(key) \n"
        }
        if (hasValue) {
          output += "\(indent) value: \(value.toRaw())\n"
        }
        unknownFields.writeDescriptionTo(&output, indent:indent)
      }
      override var hashValue:Int {
          get {
              var hashCode:Int = 7
              if hasKey {
                 hashCode = (hashCode &* 31) &+ key.hashValue
              }
              if hasValue {
                 hashCode = (hashCode &* 31) &+ Int(value.toRaw())
              }
              hashCode = (hashCode &* 31) &+  unknownFields.hashValue
              return hashCode
          }
      }
    }

    final class CheckBuilder : GeneratedMessageBuilder {
      private var builderResult:HealthResponse.Check

      required override init () {
         builderResult = HealthResponse.Check()
         super.init()
      }
      var hasKey:Bool {
           get {
                return builderResult.hasKey
           }
      }
      var key:String {
           get {
                return builderResult.key
           }
           set (value) {
               builderResult.hasKey = true
               builderResult.key = value
           }
      }
      func clearKey() -> HealthResponse.CheckBuilder{
           builderResult.hasKey = false
           builderResult.key = ""
           return self
      }
        var hasValue:Bool{
            get {
                return builderResult.hasValue
            }
        }
        var value:HealthResponse.Status {
            get {
                return builderResult.value
            }
            set (value) {
                builderResult.hasValue = true
                builderResult.value = value
            }
        }
        func clearValue() -> HealthResponse.CheckBuilder {
           builderResult.hasValue = false
           builderResult.value = .Ok
           return self
        }
      override var internalGetResult:GeneratedMessage {
           get {
              return builderResult
           }
      }
      override func clear() -> HealthResponse.CheckBuilder {
        builderResult = HealthResponse.Check()
        return self
      }
      override func clone() -> HealthResponse.CheckBuilder {
        return HealthResponse.Check.builderWithPrototype(builderResult)
      }
      func build() -> HealthResponse.Check {
           checkInitialized()
           return buildPartial()
      }
      func buildPartial() -> HealthResponse.Check {
        var returnMe:HealthResponse.Check = builderResult
        return returnMe
      }
      func mergeFrom(other:HealthResponse.Check) -> HealthResponse.CheckBuilder {
        if (other == HealthResponse.Check()) {
          return self
        }
      if other.hasKey {
           key = other.key
      }
      if other.hasValue {
           value = other.value
      }
          mergeUnknownFields(other.unknownFields)
        return self
      }
      override func mergeFromCodedInputStream(input:CodedInputStream) ->HealthResponse.CheckBuilder {
           return mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
      }
      override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponse.CheckBuilder {
        var unknownFieldsBuilder:UnknownFieldSetBuilder = UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
        while (true) {
          var tag = input.readTag()
          switch tag {
          case 0: 
            self.unknownFields = unknownFieldsBuilder.build()
            return self

          case 10 :
            key = input.readString()

          case 16 :
            var value = input.readEnum()
            var enumMergResult:HealthResponse.Status = HealthResponse.Status.fromRaw(value)!
            if (HealthResponse.Status.IsValidValue(enumMergResult)) {
                 value = enumMergResult.toRaw()
            } else {
                 unknownFieldsBuilder.mergeVarintField(2, value:Int64(value))
            }

          default:
            if (!parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:tag)) {
               unknownFields = unknownFieldsBuilder.build()
               return self
            }
          }
        }
      }
    }



  //Nested type declaration end 



  //Nested type declaration start 

    final class ExternalService : GeneratedMessage {
      private(set) var hasKey:Bool = false
      private(set) var key:String = ""

      private(set) var hasValue:Bool = false
      private(set) var value:String = ""

      required init() {
           super.init()
      }
      override func isInitialized() -> Bool {
        if !hasKey {
          return false
        }
       return true
      }
      override func writeToCodedOutputStream(output:CodedOutputStream) {
        if hasKey {
          output.writeString(1, value:key)
        }
        if hasValue {
          output.writeString(2, value:value)
        }
        unknownFields.writeToCodedOutputStream(output)
      }
      override func serializedSize() -> Int32 {
        var size:Int32 = memoizedSerializedSize
        if size != -1 {
         return size
        }

        size = 0
        if hasKey {
          size += WireFormat.computeStringSize(1, value:key)
        }
        if hasValue {
          size += WireFormat.computeStringSize(2, value:value)
        }
        size += unknownFields.serializedSize()
        memoizedSerializedSize = size
        return size
      }
      class func parseFromData(data:[Byte]) -> HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromData(data).build()
      }
      class func parseFromData(data:[Byte], extensionRegistry:ExtensionRegistry) -> HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
      }
      class func parseFromInputStream(input:NSInputStream) -> HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromInputStream(input).build()
      }
      class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) ->HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
      }
      class func parseFromCodedInputStream(input:CodedInputStream) -> HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromCodedInputStream(input).build()
      }
      class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponse.ExternalService {
        return HealthResponse.ExternalService.builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
      }
      class func builder() -> ExternalServiceBuilder {
        return ExternalServiceBuilder()
      }
      class func builderWithPrototype(prototype:ExternalService) -> ExternalServiceBuilder {
        return ExternalService.builder().mergeFrom(prototype)
      }
      func builder() -> ExternalServiceBuilder {
        return ExternalService.builder()
      }
      func toBuilder() -> ExternalServiceBuilder {
        return ExternalService.builderWithPrototype(self)
      }
      override func writeDescriptionTo(inout output:String, indent:String) {
        if hasKey {
          output += "\(indent) key: \(key) \n"
        }
        if hasValue {
          output += "\(indent) value: \(value) \n"
        }
        unknownFields.writeDescriptionTo(&output, indent:indent)
      }
      override var hashValue:Int {
          get {
              var hashCode:Int = 7
              if hasKey {
                 hashCode = (hashCode &* 31) &+ key.hashValue
              }
              if hasValue {
                 hashCode = (hashCode &* 31) &+ value.hashValue
              }
              hashCode = (hashCode &* 31) &+  unknownFields.hashValue
              return hashCode
          }
      }
    }

    final class ExternalServiceBuilder : GeneratedMessageBuilder {
      private var builderResult:HealthResponse.ExternalService

      required override init () {
         builderResult = HealthResponse.ExternalService()
         super.init()
      }
      var hasKey:Bool {
           get {
                return builderResult.hasKey
           }
      }
      var key:String {
           get {
                return builderResult.key
           }
           set (value) {
               builderResult.hasKey = true
               builderResult.key = value
           }
      }
      func clearKey() -> HealthResponse.ExternalServiceBuilder{
           builderResult.hasKey = false
           builderResult.key = ""
           return self
      }
      var hasValue:Bool {
           get {
                return builderResult.hasValue
           }
      }
      var value:String {
           get {
                return builderResult.value
           }
           set (value) {
               builderResult.hasValue = true
               builderResult.value = value
           }
      }
      func clearValue() -> HealthResponse.ExternalServiceBuilder{
           builderResult.hasValue = false
           builderResult.value = ""
           return self
      }
      override var internalGetResult:GeneratedMessage {
           get {
              return builderResult
           }
      }
      override func clear() -> HealthResponse.ExternalServiceBuilder {
        builderResult = HealthResponse.ExternalService()
        return self
      }
      override func clone() -> HealthResponse.ExternalServiceBuilder {
        return HealthResponse.ExternalService.builderWithPrototype(builderResult)
      }
      func build() -> HealthResponse.ExternalService {
           checkInitialized()
           return buildPartial()
      }
      func buildPartial() -> HealthResponse.ExternalService {
        var returnMe:HealthResponse.ExternalService = builderResult
        return returnMe
      }
      func mergeFrom(other:HealthResponse.ExternalService) -> HealthResponse.ExternalServiceBuilder {
        if (other == HealthResponse.ExternalService()) {
          return self
        }
      if other.hasKey {
           key = other.key
      }
      if other.hasValue {
           value = other.value
      }
          mergeUnknownFields(other.unknownFields)
        return self
      }
      override func mergeFromCodedInputStream(input:CodedInputStream) ->HealthResponse.ExternalServiceBuilder {
           return mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
      }
      override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponse.ExternalServiceBuilder {
        var unknownFieldsBuilder:UnknownFieldSetBuilder = UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
        while (true) {
          var tag = input.readTag()
          switch tag {
          case 0: 
            self.unknownFields = unknownFieldsBuilder.build()
            return self

          case 10 :
            key = input.readString()

          case 18 :
            value = input.readString()

          default:
            if (!parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:tag)) {
               unknownFields = unknownFieldsBuilder.build()
               return self
            }
          }
        }
      }
    }



  //Nested type declaration end 



  //Enum type declaration start 

    enum Status:Int32 {
      case Ok = 1
      case Bad = 2

      static func IsValidValue(value:Status) ->Bool {
        switch value {
          case .Ok, .Bad:
            return true;
          default:
            return false;
        }
      }
    }



  //Enum type declaration end 

  private(set) var status:HealthResponse.Status = HealthResponse.Status.Bad
  private(set) var hasStatus:Bool = false
  private(set) var hasRevision:Bool = false
  private(set) var revision:String = ""

  private(set) var nonce:HealthResponse.Status = HealthResponse.Status.Bad
  private(set) var hasNonce:Bool = false
  private(set) var timestamp:HealthResponse.Status = HealthResponse.Status.Bad
  private(set) var hasTimestamp:Bool = false
  private(set) var externalServicesStatus:HealthResponse.Status = HealthResponse.Status.Ok
  private(set) var hasExternalServicesStatus:Bool = false
  private(set) var checks:Array<HealthResponse.Check>  = Array<HealthResponse.Check>()
  private(set) var externalServices:Array<HealthResponse.ExternalService>  = Array<HealthResponse.ExternalService>()
  required init() {
       super.init()
  }
  override func isInitialized() -> Bool {
    if !hasStatus {
      return false
    }
    var isInitchecks:Bool = true
    for element in checks {
        if (!element.isInitialized()) {
            isInitchecks = false
            break 
        }
    }
    if !isInitchecks {
     return isInitchecks
     }
    var isInitexternalServices:Bool = true
    for element in externalServices {
        if (!element.isInitialized()) {
            isInitexternalServices = false
            break 
        }
    }
    if !isInitexternalServices {
     return isInitexternalServices
     }
   return true
  }
  override func writeToCodedOutputStream(output:CodedOutputStream) {
    if hasStatus {
      output.writeEnum(1, value:status.toRaw())
    }
    if hasRevision {
      output.writeString(2, value:revision)
    }
    if hasNonce {
      output.writeEnum(3, value:nonce.toRaw())
    }
    if hasTimestamp {
      output.writeEnum(4, value:timestamp.toRaw())
    }
    for element in checks {
        output.writeMessage(5, value:element)
    }
    if hasExternalServicesStatus {
      output.writeEnum(6, value:externalServicesStatus.toRaw())
    }
    for element in externalServices {
        output.writeMessage(7, value:element)
    }
    unknownFields.writeToCodedOutputStream(output)
  }
  override func serializedSize() -> Int32 {
    var size:Int32 = memoizedSerializedSize
    if size != -1 {
     return size
    }

    size = 0
    if (hasStatus) {
      size += WireFormat.computeEnumSize(1, value:status.toRaw())
    }
    if hasRevision {
      size += WireFormat.computeStringSize(2, value:revision)
    }
    if (hasNonce) {
      size += WireFormat.computeEnumSize(3, value:nonce.toRaw())
    }
    if (hasTimestamp) {
      size += WireFormat.computeEnumSize(4, value:timestamp.toRaw())
    }
    for element in checks {
        size += WireFormat.computeMessageSize(5, value:element)
    }
    if (hasExternalServicesStatus) {
      size += WireFormat.computeEnumSize(6, value:externalServicesStatus.toRaw())
    }
    for element in externalServices {
        size += WireFormat.computeMessageSize(7, value:element)
    }
    size += unknownFields.serializedSize()
    memoizedSerializedSize = size
    return size
  }
  class func parseFromData(data:[Byte]) -> HealthResponse {
    return HealthResponse.builder().mergeFromData(data).build()
  }
  class func parseFromData(data:[Byte], extensionRegistry:ExtensionRegistry) -> HealthResponse {
    return HealthResponse.builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
  }
  class func parseFromInputStream(input:NSInputStream) -> HealthResponse {
    return HealthResponse.builder().mergeFromInputStream(input).build()
  }
  class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) ->HealthResponse {
    return HealthResponse.builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  class func parseFromCodedInputStream(input:CodedInputStream) -> HealthResponse {
    return HealthResponse.builder().mergeFromCodedInputStream(input).build()
  }
  class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponse {
    return HealthResponse.builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  class func builder() -> HealthResponseBuilder {
    return HealthResponseBuilder()
  }
  class func builderWithPrototype(prototype:HealthResponse) -> HealthResponseBuilder {
    return HealthResponse.builder().mergeFrom(prototype)
  }
  func builder() -> HealthResponseBuilder {
    return HealthResponse.builder()
  }
  func toBuilder() -> HealthResponseBuilder {
    return HealthResponse.builderWithPrototype(self)
  }
  override func writeDescriptionTo(inout output:String, indent:String) {
    if (hasStatus) {
      output += "\(indent) status: \(status.toRaw())\n"
    }
    if hasRevision {
      output += "\(indent) revision: \(revision) \n"
    }
    if (hasNonce) {
      output += "\(indent) nonce: \(nonce.toRaw())\n"
    }
    if (hasTimestamp) {
      output += "\(indent) timestamp: \(timestamp.toRaw())\n"
    }
    var checksElementIndex:Int = 0
    for element in checks {
        output += "\(indent) checks[\(checksElementIndex)] {\n"
        element.writeDescriptionTo(&output, indent:"\(indent)  ")
        output += "\(indent)}\n"
        checksElementIndex++
    }
    if (hasExternalServicesStatus) {
      output += "\(indent) externalServicesStatus: \(externalServicesStatus.toRaw())\n"
    }
    var externalServicesElementIndex:Int = 0
    for element in externalServices {
        output += "\(indent) externalServices[\(externalServicesElementIndex)] {\n"
        element.writeDescriptionTo(&output, indent:"\(indent)  ")
        output += "\(indent)}\n"
        externalServicesElementIndex++
    }
    unknownFields.writeDescriptionTo(&output, indent:indent)
  }
  override var hashValue:Int {
      get {
          var hashCode:Int = 7
          if hasStatus {
             hashCode = (hashCode &* 31) &+ Int(status.toRaw())
          }
          if hasRevision {
             hashCode = (hashCode &* 31) &+ revision.hashValue
          }
          if hasNonce {
             hashCode = (hashCode &* 31) &+ Int(nonce.toRaw())
          }
          if hasTimestamp {
             hashCode = (hashCode &* 31) &+ Int(timestamp.toRaw())
          }
          for element in checks {
              hashCode = (hashCode &* 31) &+ element.hashValue
          }
          if hasExternalServicesStatus {
             hashCode = (hashCode &* 31) &+ Int(externalServicesStatus.toRaw())
          }
          for element in externalServices {
              hashCode = (hashCode &* 31) &+ element.hashValue
          }
          hashCode = (hashCode &* 31) &+  unknownFields.hashValue
          return hashCode
      }
  }
}

final class HealthResponseBuilder : GeneratedMessageBuilder {
  private var builderResult:HealthResponse

  required override init () {
     builderResult = HealthResponse()
     super.init()
  }
    var hasStatus:Bool{
        get {
            return builderResult.hasStatus
        }
    }
    var status:HealthResponse.Status {
        get {
            return builderResult.status
        }
        set (value) {
            builderResult.hasStatus = true
            builderResult.status = value
        }
    }
    func clearStatus() -> HealthResponseBuilder {
       builderResult.hasStatus = false
       builderResult.status = .Bad
       return self
    }
  var hasRevision:Bool {
       get {
            return builderResult.hasRevision
       }
  }
  var revision:String {
       get {
            return builderResult.revision
       }
       set (value) {
           builderResult.hasRevision = true
           builderResult.revision = value
       }
  }
  func clearRevision() -> HealthResponseBuilder{
       builderResult.hasRevision = false
       builderResult.revision = ""
       return self
  }
    var hasNonce:Bool{
        get {
            return builderResult.hasNonce
        }
    }
    var nonce:HealthResponse.Status {
        get {
            return builderResult.nonce
        }
        set (value) {
            builderResult.hasNonce = true
            builderResult.nonce = value
        }
    }
    func clearNonce() -> HealthResponseBuilder {
       builderResult.hasNonce = false
       builderResult.nonce = .Bad
       return self
    }
    var hasTimestamp:Bool{
        get {
            return builderResult.hasTimestamp
        }
    }
    var timestamp:HealthResponse.Status {
        get {
            return builderResult.timestamp
        }
        set (value) {
            builderResult.hasTimestamp = true
            builderResult.timestamp = value
        }
    }
    func clearTimestamp() -> HealthResponseBuilder {
       builderResult.hasTimestamp = false
       builderResult.timestamp = .Bad
       return self
    }
  var checks:Array<HealthResponse.Check> {
       get {
           return builderResult.checks
       }
       set (value) {
           builderResult.checks = value
       }
  }
  func clearChecks() -> HealthResponseBuilder {
    builderResult.checks.removeAll(keepCapacity: false)
    return self
  }
    var hasExternalServicesStatus:Bool{
        get {
            return builderResult.hasExternalServicesStatus
        }
    }
    var externalServicesStatus:HealthResponse.Status {
        get {
            return builderResult.externalServicesStatus
        }
        set (value) {
            builderResult.hasExternalServicesStatus = true
            builderResult.externalServicesStatus = value
        }
    }
    func clearExternalServicesStatus() -> HealthResponseBuilder {
       builderResult.hasExternalServicesStatus = false
       builderResult.externalServicesStatus = .Ok
       return self
    }
  var externalServices:Array<HealthResponse.ExternalService> {
       get {
           return builderResult.externalServices
       }
       set (value) {
           builderResult.externalServices = value
       }
  }
  func clearExternalServices() -> HealthResponseBuilder {
    builderResult.externalServices.removeAll(keepCapacity: false)
    return self
  }
  override var internalGetResult:GeneratedMessage {
       get {
          return builderResult
       }
  }
  override func clear() -> HealthResponseBuilder {
    builderResult = HealthResponse()
    return self
  }
  override func clone() -> HealthResponseBuilder {
    return HealthResponse.builderWithPrototype(builderResult)
  }
  func build() -> HealthResponse {
       checkInitialized()
       return buildPartial()
  }
  func buildPartial() -> HealthResponse {
    var returnMe:HealthResponse = builderResult
    return returnMe
  }
  func mergeFrom(other:HealthResponse) -> HealthResponseBuilder {
    if (other == HealthResponse()) {
      return self
    }
  if other.hasStatus {
       status = other.status
  }
  if other.hasRevision {
       revision = other.revision
  }
  if other.hasNonce {
       nonce = other.nonce
  }
  if other.hasTimestamp {
       timestamp = other.timestamp
  }
  if !other.checks.isEmpty  {
     builderResult.checks += other.checks
  }
  if other.hasExternalServicesStatus {
       externalServicesStatus = other.externalServicesStatus
  }
  if !other.externalServices.isEmpty  {
     builderResult.externalServices += other.externalServices
  }
      mergeUnknownFields(other.unknownFields)
    return self
  }
  override func mergeFromCodedInputStream(input:CodedInputStream) ->HealthResponseBuilder {
       return mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
  }
  override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthResponseBuilder {
    var unknownFieldsBuilder:UnknownFieldSetBuilder = UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
    while (true) {
      var tag = input.readTag()
      switch tag {
      case 0: 
        self.unknownFields = unknownFieldsBuilder.build()
        return self

      case 8 :
        var value = input.readEnum()
        var enumMergResult:HealthResponse.Status = HealthResponse.Status.fromRaw(value)!
        if (HealthResponse.Status.IsValidValue(enumMergResult)) {
             status = enumMergResult
        } else {
             unknownFieldsBuilder.mergeVarintField(1, value:Int64(value))
        }

      case 18 :
        revision = input.readString()

      case 24 :
        var value = input.readEnum()
        var enumMergResult:HealthResponse.Status = HealthResponse.Status.fromRaw(value)!
        if (HealthResponse.Status.IsValidValue(enumMergResult)) {
             nonce = enumMergResult
        } else {
             unknownFieldsBuilder.mergeVarintField(3, value:Int64(value))
        }

      case 32 :
        var value = input.readEnum()
        var enumMergResult:HealthResponse.Status = HealthResponse.Status.fromRaw(value)!
        if (HealthResponse.Status.IsValidValue(enumMergResult)) {
             timestamp = enumMergResult
        } else {
             unknownFieldsBuilder.mergeVarintField(4, value:Int64(value))
        }

      case 42 :
        var subBuilder = HealthResponse.Check.builder()
        input.readMessage(subBuilder,extensionRegistry:extensionRegistry)
        checks += [subBuilder.buildPartial()]

      case 48 :
        var value = input.readEnum()
        var enumMergResult:HealthResponse.Status = HealthResponse.Status.fromRaw(value)!
        if (HealthResponse.Status.IsValidValue(enumMergResult)) {
             externalServicesStatus = enumMergResult
        } else {
             unknownFieldsBuilder.mergeVarintField(6, value:Int64(value))
        }

      case 58 :
        var subBuilder = HealthResponse.ExternalService.builder()
        input.readMessage(subBuilder,extensionRegistry:extensionRegistry)
        externalServices += [subBuilder.buildPartial()]

      default:
        if (!parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:tag)) {
           unknownFields = unknownFieldsBuilder.build()
           return self
        }
      }
    }
  }
}

final class HealthRequest : GeneratedMessage {
  required init() {
       super.init()
  }
  override func isInitialized() -> Bool {
   return true
  }
  override func writeToCodedOutputStream(output:CodedOutputStream) {
    unknownFields.writeToCodedOutputStream(output)
  }
  override func serializedSize() -> Int32 {
    var size:Int32 = memoizedSerializedSize
    if size != -1 {
     return size
    }

    size = 0
    size += unknownFields.serializedSize()
    memoizedSerializedSize = size
    return size
  }
  class func parseFromData(data:[Byte]) -> HealthRequest {
    return HealthRequest.builder().mergeFromData(data).build()
  }
  class func parseFromData(data:[Byte], extensionRegistry:ExtensionRegistry) -> HealthRequest {
    return HealthRequest.builder().mergeFromData(data, extensionRegistry:extensionRegistry).build()
  }
  class func parseFromInputStream(input:NSInputStream) -> HealthRequest {
    return HealthRequest.builder().mergeFromInputStream(input).build()
  }
  class func parseFromInputStream(input:NSInputStream, extensionRegistry:ExtensionRegistry) ->HealthRequest {
    return HealthRequest.builder().mergeFromInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  class func parseFromCodedInputStream(input:CodedInputStream) -> HealthRequest {
    return HealthRequest.builder().mergeFromCodedInputStream(input).build()
  }
  class func parseFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthRequest {
    return HealthRequest.builder().mergeFromCodedInputStream(input, extensionRegistry:extensionRegistry).build()
  }
  class func builder() -> HealthRequestBuilder {
    return HealthRequestBuilder()
  }
  class func builderWithPrototype(prototype:HealthRequest) -> HealthRequestBuilder {
    return HealthRequest.builder().mergeFrom(prototype)
  }
  func builder() -> HealthRequestBuilder {
    return HealthRequest.builder()
  }
  func toBuilder() -> HealthRequestBuilder {
    return HealthRequest.builderWithPrototype(self)
  }
  override func writeDescriptionTo(inout output:String, indent:String) {
    unknownFields.writeDescriptionTo(&output, indent:indent)
  }
  override var hashValue:Int {
      get {
          var hashCode:Int = 7
          hashCode = (hashCode &* 31) &+  unknownFields.hashValue
          return hashCode
      }
  }
}

final class HealthRequestBuilder : GeneratedMessageBuilder {
  private var builderResult:HealthRequest

  required override init () {
     builderResult = HealthRequest()
     super.init()
  }
  override var internalGetResult:GeneratedMessage {
       get {
          return builderResult
       }
  }
  override func clear() -> HealthRequestBuilder {
    builderResult = HealthRequest()
    return self
  }
  override func clone() -> HealthRequestBuilder {
    return HealthRequest.builderWithPrototype(builderResult)
  }
  func build() -> HealthRequest {
       checkInitialized()
       return buildPartial()
  }
  func buildPartial() -> HealthRequest {
    var returnMe:HealthRequest = builderResult
    return returnMe
  }
  func mergeFrom(other:HealthRequest) -> HealthRequestBuilder {
    if (other == HealthRequest()) {
      return self
    }
      mergeUnknownFields(other.unknownFields)
    return self
  }
  override func mergeFromCodedInputStream(input:CodedInputStream) ->HealthRequestBuilder {
       return mergeFromCodedInputStream(input, extensionRegistry:ExtensionRegistry())
  }
  override func mergeFromCodedInputStream(input:CodedInputStream, extensionRegistry:ExtensionRegistry) -> HealthRequestBuilder {
    var unknownFieldsBuilder:UnknownFieldSetBuilder = UnknownFieldSet.builderWithUnknownFields(self.unknownFields)
    while (true) {
      var tag = input.readTag()
      switch tag {
      case 0: 
        self.unknownFields = unknownFieldsBuilder.build()
        return self

      default:
        if (!parseUnknownField(input,unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:tag)) {
           unknownFields = unknownFieldsBuilder.build()
           return self
        }
      }
    }
  }
}

//Class extensions: NSData


extension HealthResponse.Check {
    class func parseFromNSData(data:NSData) -> HealthResponse.Check {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.Check.builder().mergeFromData(bytes).build()
    }
    class func parseFromNSData(data:NSData, extensionRegistry:ExtensionRegistry) -> HealthResponse.Check {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.Check.builder().mergeFromData(bytes, extensionRegistry:extensionRegistry).build()
    }
}
extension HealthResponse.ExternalService {
    class func parseFromNSData(data:NSData) -> HealthResponse.ExternalService {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.ExternalService.builder().mergeFromData(bytes).build()
    }
    class func parseFromNSData(data:NSData, extensionRegistry:ExtensionRegistry) -> HealthResponse.ExternalService {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.ExternalService.builder().mergeFromData(bytes, extensionRegistry:extensionRegistry).build()
    }
}
extension HealthResponse {
    class func parseFromNSData(data:NSData) -> HealthResponse {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.builder().mergeFromData(bytes).build()
    }
    class func parseFromNSData(data:NSData, extensionRegistry:ExtensionRegistry) -> HealthResponse {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthResponse.builder().mergeFromData(bytes, extensionRegistry:extensionRegistry).build()
    }
}
extension HealthRequest {
    class func parseFromNSData(data:NSData) -> HealthRequest {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthRequest.builder().mergeFromData(bytes).build()
    }
    class func parseFromNSData(data:NSData, extensionRegistry:ExtensionRegistry) -> HealthRequest {
        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes)
        return HealthRequest.builder().mergeFromData(bytes, extensionRegistry:extensionRegistry).build()
    }
}

// @@protoc_insertion_point(global_scope)
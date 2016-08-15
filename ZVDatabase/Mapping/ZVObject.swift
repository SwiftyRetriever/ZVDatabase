//
//  ZVObject.swift
//  ZVDatabase
//
//  Created by ZERO on 16/8/6.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public class ZVObject: NSObject {
    
    public required override init() {}
    
    // you need override this method to figure out the primary key and the property of primary key.
    public func primaryKey() -> (key: String, autoincrement: Bool)? {
        return nil
    }
}

//MARK: - toDictionary
internal extension ZVObject {
    /*
    func type2() -> Any.Type {
        return Int.Type()
    }*/
    
    internal func dictionaryValue(skip:[String] = []) -> [String: Bindable] {
        
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: Bindable]()
        
        for child in mirror.children {
            if let label = child.label {
                if skip.contains(label) { continue }
                let val = _value(for: child.value)
                dictionary[label] = val
            }
        }
        
        return dictionary
    }
    
    private func _value(for anyValue: Any) -> Bindable {
        
        var theValue = anyValue
        
        let mirror = Mirror(reflecting: theValue)
        
        if mirror.displayStyle == .optional {
            if mirror.children.count == 1 {
                theValue = _value(for: mirror.children.first!.value)
            } else if mirror.children.count == 0 {
                return NSNull()
            }
        }
        
        switch theValue {
        case let value as  Int64:
            return NSDecimalNumber(value: value)
        case let value as Int32:
            return NSDecimalNumber(value: value)
        case let value as Int16:
            return NSDecimalNumber(value: value)
        case let value as Int8:
            return NSDecimalNumber(value: value)
        case let value as UInt64:
            return NSDecimalNumber(value: value)
        case let value as UInt32:
            return NSDecimalNumber(value: value)
        case let value as UInt16:
            return NSDecimalNumber(value: value)
        case let value as UInt8:
            return NSDecimalNumber(value: value)
        case let value as Double:
            return NSDecimalNumber(value: value)
        case let value as Float:
            return NSDecimalNumber(value: value)
        case let value as NSNumber:
            return value
        case let value as String:
            return value
        case let value as NSArray:
            if let val = value as? Array<ZVObject> {
                return val.map({ item in return item.dictionaryValue() })
            } else {
                return value
            }
        case let value as NSDictionary:
            if let val = value as? Dictionary<String, ZVObject> {
                var dictioanry = [String: [String: Bindable]]()
                for (k, v) in val {
                    dictioanry[k] = v.dictionaryValue()
                }
                return dictioanry
            } else {
                return value
            }
        case let value as Date:
            return value
        case let value as ZVObject:
            return value.dictionaryValue()
        default:
            return NSNull()
        }
    }
}

//MARK: - Fields
internal extension ZVObject {
    
    internal func fields() -> [String: String] {
        
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: String]()
        
        for child in mirror.children {
            
            if let label = child.label {
                let val = _type(for: child.value)
                
                if self.primaryKey()?.key == label {
                    var type = val.type() + " " + "PRMARY KEY"
                    let autoincrement = (self.primaryKey()?.autoincrement ?? false) ? " AUTO_INCREMENT " : ""
                    type += autoincrement
                    
                    dictionary[label] = type
                    continue
                }
                
                dictionary[label] = val.type()
            }
        }
        
        return dictionary
    }
    
    private func _type(for anyValue: Any) -> ObjectType {
        
        let type = Mirror(reflecting: anyValue).subjectType
        let typeName = _getClassName(name: String(type))
        
        return ObjectType.value(from: _getClassName(name: typeName))
    }
    
    private func _getClassName(name: String) -> String {
        
        if name.hasPrefix("Dictionary")  {
            return "NSDictionary"
        } else if name.hasPrefix("Array"){
            return "NSArray"
        }
        
        let range = name.range(of: "<.*>", options: .regularExpression)
        
        if range == nil {
            return name
        } else {
            let subName = name.substring(with: range!)
            let subRange = subName.index(subName.startIndex , offsetBy: 1) ..< subName.index(subName.endIndex , offsetBy: -1)
            
            return _getClassName(name: subName.substring(with: subRange))
        }
    }
}


//MARK: - set(value: Any, for key: String)

public typealias Element = (label: String, type: Any)

public extension ZVObject {
    
    public convenience init(dictionary: [String: AnyObject]) {
        
        self.init()
        
        _getValue(from: dictionary)
    }
    
    private func _getValue(from dictionary: [String: AnyObject]) {
        
        let mirror:Mirror! = Mirror(reflecting: self)
        
        if let collection = AnyBidirectionalCollection(mirror.children) {
            
            var index = collection.index(collection.endIndex,
                                         offsetBy: -collection.count,
                                         limitedBy: collection.startIndex) ?? collection.startIndex
            
            while index != collection.endIndex {
                
                let element = collection[index]
                if let label = element.label {
                    
                    let value = _getValue(by: Element(label: label, type: element.value), from: dictionary)
                    
                    if let val = value {
                        // print(val)
                        self.setValue(val, forKey: label)
                    }
                    collection.formIndex(after: &index)
                }
            }
        }
    }
    
    private func _getType(by anyValue: Any) -> Any {
        
        var theValue = anyValue
        
        let mirror = Mirror(reflecting: theValue)
        
        if mirror.displayStyle == .optional {
            if mirror.children.count == 1 {
                theValue = _getType(by: mirror.children.first!.value)
                    // _getType(by: mirror.children.first!.value)
            }
        }
        
        return theValue
    }
    
    private func _getValue(by element: Element , from dictionary: [String: AnyObject]) -> AnyObject? {
        
        // print(Mirror(reflecting: element.type).subjectType)
        var objectValue: AnyObject?
        switch element.type {
        case is Int, is Int8, is Int16, is Int32, is Int64,
             is UInt, is UInt8, is UInt16, is UInt32, is UInt64, is NSNumber,
             is Double, is Float,
             is Bool:
            
            objectValue = _getNumberValue(by: element, from: dictionary)
            break
        case is String, is NSString:
            objectValue = _getStringValue(by: element, from: dictionary)
            break
        case is NSArray:
            objectValue = _getArrayValue(by: element, from: dictionary)
            break
        case is NSDictionary:
            objectValue = _getDictionaryValue(by: element, from: dictionary)
            break
        default:
            break
        }
        
        return objectValue
    }
    
    private func _getNumberValue(by element: Element,
                                 from dictionary: [String: AnyObject]) -> AnyObject? {
        
        let objectValue = dictionary[element.label]

        switch objectValue {
        case let value as String:
            return NSDecimalNumber(string: value)
        case let value as NSNumber:
            return value
        case let value as Int8:
            return NSDecimalNumber(value: value)
        case let value as UInt8:
            return NSDecimalNumber(value: value)
        case let value as Int16:
            return NSDecimalNumber(value: value)
        case let value as UInt16:
            return NSDecimalNumber(value: value)
        case let value as Int32:
            return NSDecimalNumber(value: value)
        case let value as UInt32:
            return NSDecimalNumber(value: value)
        case let value as Int64:
            return NSDecimalNumber(value: value)
        case let value as UInt64:
            return NSDecimalNumber(value: value)
        case let value as Float:
            return NSDecimalNumber(value: value)
        case let value as Double:
            return NSDecimalNumber(value: value)
        case let value as Data:
            let string = String(data: value, encoding: .utf8)
            return NSDecimalNumber(string: string)
        default:
            return objectValue
        }
    }

    private func _getStringValue(by element: Element,
                                 from dictionary: [String: AnyObject]) -> AnyObject? {
        
        let objectValue = dictionary[element.label]
        switch objectValue {
        case let value as String:
            return value
        case let value as Data:
            let string = String(data: value, encoding: .utf8)
            return string
        default:
            if let val = objectValue {
                return String(val)
            } else {
                return nil
            }
        }
    }
    
    private func _getArrayValue(by element: Element,
                                from dictionary: [String: AnyObject]) -> NSArray? {

        if let objectValue = dictionary[element.label] as? NSArray {
            return objectValue
        }
        
        return nil
    }
    
    private func _getDictionaryValue(by element: Element,
                                     from dictionary: [String: AnyObject]) -> NSDictionary? {
        
        if let objectValue = dictionary[element.label] as? NSDictionary {
            return objectValue
        }
        
        return nil
    }
}


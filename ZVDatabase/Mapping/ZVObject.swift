//
//  ZVObject.swift
//  ZVDatabase
//
//  Created by naver on 16/7/28.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public protocol ZVObjectProtocol: NSObjectProtocol {
    
    init()
}

public class ZVObject: NSObject, ZVObjectProtocol {

    public required override init() {}
    
    public func dictionaryValue() -> [String: AnyObject] {
        
        let mirror = Mirror(reflecting: self)
        var dictionary = [String: AnyObject]()
        
        for child in mirror.children {
            if let label = child.label {
                let val = value(for: child.value)
                dictionary[label] = val
            }
        }
        
        return dictionary
    }
    
//    public func value(for anyValue: Any) -> AnyObject {
//        
//        let mirror = Mirror(reflecting: anyValue)
//        if mirror.displayStyle == .optional {
//            print(mirror)
//        } else if mirror.displayStyle == .struct {
//            
//        } else if mirror.displayStyle == .class {
//            print("else if mirror.displayStyle == .class \(mirror)")
//        } else if mirror.displayStyle == .enum {
//            
//        } else if mirror.displayStyle == .tuple {
//            
//        } else if mirror.displayStyle == .collection {
//            
//        } else if mirror.displayStyle == .dictionary {
//            
//        } else if mirror.displayStyle == .set {
//            
//        }
//        
//        return value(forDetail: anyValue)
//    }
    
    func value(for anyValue: Any) -> AnyObject {
        
        switch anyValue {
        case is Int64:
            return NSDecimalNumber(value: anyValue as! Int64)
        case is Int32:
            return NSDecimalNumber(value: anyValue as! Int32)
        case is Int16:
            return NSDecimalNumber(value: anyValue as! Int16)
        case is Int8:
            return NSDecimalNumber(value: anyValue as! Int8)
        case is UInt64:
            return NSDecimalNumber(value: anyValue as! UInt64)
        case is UInt32:
            return NSDecimalNumber(value: anyValue as! UInt32)
        case is UInt16:
            return NSDecimalNumber(value: anyValue as! UInt16)
        case is UInt8:
            return NSDecimalNumber(value: anyValue as! UInt8)
        case is Double:
            return NSDecimalNumber(value: anyValue as! Double)
        case is Float:
            return NSDecimalNumber(value: anyValue as! Float)
        case is NSNumber, is Int, is UInt:
            return anyValue as! NSNumber
        case is String, is NSString:
            return anyValue as! String
        case is UUID:
            return anyValue as! UUID
        case is NSArray:
            let mirror = Mirror(reflecting: anyValue)
            if mirror.subjectType is ZVObject.Type {
                let value = anyValue as! [ZVObject]
                var array = [[String: AnyObject]]()
                for item in value {
                    array.append(item.dictionaryValue())
                }
                return array
            } else {
                return anyValue as! NSArray
            }
        case is NSDictionary:
            let mirror = Mirror(reflecting: anyValue)
            if mirror.subjectType is Dictionary<String, ZVObject>.Type {
                let value = anyValue as! [String: ZVObject]
                var dictioanry = [String: [String: AnyObject]]()
                for (key, val) in value {
                    dictioanry[key] = val.dictionaryValue()
                }
                return dictioanry
            } else {
                return anyValue as! NSDictionary
            }
        case is Date:
            return anyValue as! Date
        case is ZVObject:
            let value = anyValue as! ZVObject
            return value.dictionaryValue()
        default:
            return NSNull()
        }
    }
}

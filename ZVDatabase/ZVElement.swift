//
//  ZVElement.swift
//  ZVAddressBook
//
//  Created by ZERO on 16/6/29.
//  Copyright © 2016年 小零心语. All rights reserved.
//

import UIKit

public final class ZVSQLRow: NSObject {
    
    override init() { }
    
    private var _data = Dictionary<String, ZVSQLColumn>()
    
    public subscript(key: String) -> ZVSQLColumn? {
        get {
            return _data[key]
        }
        
        set(newVal) {
            _data[key] = newVal
        }
    }
    
    public override var description: String {
        var desc: String = "\n[\n"
        for (k, v) in _data {
            desc.append("key: \(k), value: \(v) \n")
        }
        desc.append("]")
        return desc
    }
}

public final class ZVSQLColumn: NSObject {
    
    internal var value: AnyObject? = nil
    internal var type: CInt = -1
    internal var statement: OpaquePointer? = nil
    
    internal init(value: AnyObject?, type: CInt) {
        self.value = value
        self.type = type
    }
    
    internal init(statement: OpaquePointer?) {
        self.statement = statement
    }
    
    public override var description: String {
        return String(self.value ?? "") ?? ""
    }
}

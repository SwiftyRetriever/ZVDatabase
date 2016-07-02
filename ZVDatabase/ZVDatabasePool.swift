//
//  ZVDatabasePool.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

class ZVDatabasePool: NSObject {
    
    private struct Singleton {
        static var pool: ZVDatabasePool?
    }
    
    static let shared: ZVDatabasePool = ZVDatabasePool()
    
    override class func initialize() {
        super.initialize()
    }
    
}

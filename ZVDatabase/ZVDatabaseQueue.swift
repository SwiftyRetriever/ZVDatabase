//
//  ZVDatabaseQueue.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

public class ZVDatabaseQueue: NSObject {
    
    private var queue: DispatchQueue?
    private var connection: ZVConnection?
    
    private override init() {}
    
    public init(path: String) {
        
        self.connection = ZVConnection(path: path)
        
        let queueName = "com.zevwings." + path
        queue = DispatchQueue(label: queueName)
        
    }
    
    public init(path: String = "", queue: DispatchQueue) {
        
        self.connection = ZVConnection(path: path)
        self.queue = queue
    }
    
    public func inBlock(_ block: (db: ZVConnection) -> Void) {
        
        if let queue = self.queue {
            queue.async(execute: {
                block(db: self.connection!)
            })
        }
    }
    
    public func inTransaction(_ deferred: Bool = false, _ block: (db: ZVConnection) -> Bool) {
        
        do {
            try self.connection!.open()
        } catch {
            print(error)
        }
        
        queue?.async(execute: {
            
            var success = false
            
            if deferred {
                success = self.connection!.beginDeferredTransaction()
            } else {
                success = self.connection!.beginTransaction()
            }
            
            if success {
                
                if block(db: self.connection!) {
                    
                    self.connection!.commit()
                    do { try self.connection!.close() } catch {}
                } else {
                    
                    self.connection!.rollback()
                    do { try self.connection!.close() } catch {}
                }
            } else {
                
                do { try self.connection!.close() } catch {}
            }
        })
    }
}

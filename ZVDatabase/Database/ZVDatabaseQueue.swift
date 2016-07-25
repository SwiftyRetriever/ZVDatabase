//
//  ZVDatabaseQueue.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit

public final class ZVDatabaseQueue: NSObject {
    
    private var _queue: DispatchQueue?
    private var _connection: ZVConnection?
    
    private override init() {}
    
    public init(path: String) {
        
        _connection = ZVConnection(path: path)
        _queue = DispatchQueue(label: "com.zevwings.db.queue")
        
    }
    
    public init(path: String = "", queue: DispatchQueue) {
        
        _connection = ZVConnection(path: path)
        _queue = queue
    }
    
    public func inBlock(_ block: (db: ZVConnection) -> Void) {
        
        if let queue = _queue {
            queue.async(execute: {
                block(db: self._connection!)
            })
        }
    }
    
    public func inTransaction(transactionType type: ZVTransactionType = .deferred,
                              _ block: (db: ZVConnection) -> Bool) {
        
        do {
            try _connection!.open()
        } catch {
            print(error)
        }
        
        _queue?.async(execute: {
            
            var success = false
            
            switch type {
            case .deferred:
                success = self._connection!.beginDeferredTransaction()
                break
            case .exclusive:
                success = self._connection!.beginExclusiveTransaction()
                break
            case .immediate:
                success = self._connection!.beginImmediateTransaction()
                break
            }
            
            if success {
                
                if block(db: self._connection!) {
                    
                    self._connection!.commit()
                    do { try self._connection!.close() } catch {}
                } else {
                    
                    self._connection!.rollback()
                    do { try self._connection!.close() } catch {}
                }
            } else {
                
                do { try self._connection!.close() } catch {}
            }
        })
    }
}

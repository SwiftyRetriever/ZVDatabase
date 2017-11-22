//
//  ZVDatabaseQueue.swift
//  ZVDatabase
//
//  Created by zevwings on 16/6/27.
//  Copyright © 2016年 zevwings. All rights reserved.
//

import UIKit


public final class DatabaseQueue: NSObject {
    
    private var _queue: DispatchQueue?
    private var _connection: Connection?
    
    private override init() {}
    
    public init(path: String) {
        
        _connection = Connection(path: path)
        let label = path.isEmpty ? "queue" : path
        _queue = DispatchQueue(label: "com.zevwings.db.\(label)")
    }
    
    public init(path: String = "", queue: DispatchQueue) {
        
        _connection = Connection(path: path)
        _queue = queue
    }
    
    public func inBlock(_ block: @escaping (_ db: Connection) -> Void) {
        
        if let queue = _queue {
            queue.async {
                block(self._connection!)
            }
        }
    }
    
    public func inTransaction(transactionType type: TransactionType = .deferred,
                              _ block: @escaping (_ db: Connection) -> Bool) {
        
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
                
                if block(self._connection!) {
                    
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
    
    public func inSavePoint(with name: String,
                            _ block: @escaping (_ db: Connection) -> Bool) {
        
        do {
            try _connection!.open()
        } catch {
            print(error)
        }
        
        _queue?.async(execute: {
            
            let success = self._connection!.beginSavepoint(with: name)
            
            if success {

                if block(self._connection!) {
                    
                } else {
                    self._connection!.rollbackSavepoint(with: name)
                }
                
                self._connection!.releaseSavepoint(with: name)
            }
        })
    }
}

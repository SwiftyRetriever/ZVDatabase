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
    
    /**
     
     - parameter path: String
     
     */
    public init(path: String) {
        
        _connection = Connection(path: path)
        let label = path.isEmpty ? "queue" : String(path.hashValue)
        _queue = DispatchQueue(label: "com.zevwings.db.\(label)")
    }
    
    /**
     
     - parameter path:  String
     - parameter queue: DispatchQueue
     
     */
    public init(path: String = "", queue: DispatchQueue) {
        
        _connection = Connection(path: path)
        _queue = queue
    }
    
    /**
     在线程中执行数据库
     
     - parameter block: Closure
     */
    public func inBlock(_ block: (db: Connection) -> Void) {
        
        if let queue = _queue {
            queue.async {
                block(db: self._connection!)
            }
        }
    }
    
    /**
     在线程中执行数据库并开启事务
     
     - parameter type:  事务类型
     - parameter block: Closure
     */
    public func inTransaction(transactionType type: TransactionType = .deferred,
                              _ block: (db: Connection) -> Bool) {
        
        do {
            try _connection!.open()
        } catch {
            print(error)
        }
        
        _queue?.async(execute: {
            
            let success = self._connection!.begin(transaction: type)
            
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
    
    /**
     在线程中执行数据库并开启SAVEPOINT
     
     - parameter name:  String
     - parameter block: Closure
     */
    public func inSavePoint(with name: String,
                            _ block: (db: Connection) -> Bool) {
        
        do {
            try _connection!.open()
        } catch {
            print(error)
        }
        
        _queue?.async(execute: {
            
            let success = self._connection!.beginSavepoint(with: name)
            
            if success {

                if block(db: self._connection!) {
                    
                } else {
                    self._connection!.rollbackSavepoint(with: name)
                }
                
                self._connection!.releaseSavepoint(with: name)
            }
        })
    }
}

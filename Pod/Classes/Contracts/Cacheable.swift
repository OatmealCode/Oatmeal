//
//  Cacheable.swift
//  Pods
//
//  Created by Michael Kantor on 9/14/15.
//
//

import Foundation

public protocol Cacheable : Resolveable{
    
    func get(key: String,completion:(response: ResponseHandler) -> Void)
    func set<T:Resolveable>(key:String,value:T)
}
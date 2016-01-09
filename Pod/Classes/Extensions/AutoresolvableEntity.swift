//
//  AutoresolvableEntity.swift
//  Pods
//
//  Created by Michael Kantor on 1/3/16.
//
//

import Foundation
import CoreFoundation

//https://raw.githubusercontent.com/apple/swift-corelibs-foundation/master/Foundation/NSObject.swift


extension Autoresolves
{
    
    public func setValue(value: AnyObject!, forUndefinedKey key: String)
    {
        
        if let log : FileLog = ~Oats()
        {
            log.error("\nWARNING: The object '\(value.dynamicType)' is not bridgable to ObjectiveC")
        }
        
    }
    
}
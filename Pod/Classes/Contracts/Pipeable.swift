//
//  Pipeable.swift
//  Pods
//
//  Created by Michael Kantor on 8/22/15.
//
//

import Foundation


public protocol Initable {
    init()
}

public protocol Pipeable
{
    var name : String { get set}
    
    func getName()->String
    
    func setName(name:String)
    
    func isPipeReadyForMiddleware()->Bool
}

//
// Created by Michael Kantor on 2/13/15.
// Copyright (c) 2015 Michael Kantor. All rights reserved.
//

import Foundation


public class Event {
    
    public typealias handler = (event : Event) -> ()
    
    public var name           : String?
    
    public var namespace      : String?
    
    public var lastFiredAt    : Int?
    
    public var data           : [String : AnyObject]?
    
    public var callback       : handler?
    
    public let reoccuring     : Bool
    
    public var fired          : Int
    
    public func handle()
    {    
        lastFiredAt = Int(NSDate().timeIntervalSince1970)
        fired += 1
        callback!(event: self)
    }
    
    init(name : String,isReoccuring : Bool = true, namespace : String = "global"){
        self.name            = name
        self.reoccuring      = isReoccuring
        self.namespace       = namespace
        self.fired           = 0
    }
    
}
 //
 //  Resolveable.swift
 //  Pods
 //
 //  Created by Michael Kantor on 8/22/15.
 //
 //

import Carlos
import SwiftyJSON
 
 public protocol Resolveable : ExpensiveObject
 {
     /**
         - var entityName : the alternative name for the resolved object
     **/
    
     static var entityName: String? { get set }
     init()
     func dependencies(properties : properties?) -> properties
     func toProps(fromJson : Bool) -> properties
     func getName() -> String
     func toJSON() -> JSON
     func resolvableFilter(prop: Property) ->DidResolve
 }
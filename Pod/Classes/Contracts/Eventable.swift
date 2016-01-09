//
//  Events.swift
//  Pods
//
//  Created by Michael Kantor on 9/14/15.
//
//

import Foundation

protocol Eventable : Resolveable
{
    func fire(event : String, payload : [String : AnyObject]?) -> (Bool,Event?)
    func listenFor(event : String, global : Bool, handler : (event : Event) -> Void)
    func listenFor(event:String,namespace:String,handler : (event : Event) -> Void)
    func flush()
    func dispose(event : String)
    func get(key:String) -> Event?
    func has(key:String)->Bool
}
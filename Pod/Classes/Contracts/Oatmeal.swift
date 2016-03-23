//
//  Oatmeal.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//

import Foundation
 
public protocol Oatmeal : Resolveable
{
    var singletons : [Resolveable]{
        get set 
    }
    init()
    func get(key:String)->Resolveable?
    func get<O:Resolveable>() -> O?
    func has(key:String)->Bool
    func has(key:Resolveable.Type)->Bool
    func bind(member: Resolveable)
    func unbind(member: Resolveable)
    func bind(key:String, member:Resolveable.Type)
    func bindSingleton(singleton : Resolveable)
    func unbindSingleton(singleton:Resolveable)
    func bindIf(condition : ()->Bool, withMember : Resolveable.Type, completion : ()->())
    func register(provider:ServiceProvider)
    func register(providers:[ServiceProvider])
    func injectDependencies(obj: Autoresolves)
    func getDynamicName(name:String) -> String
}

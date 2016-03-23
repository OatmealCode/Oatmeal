//
//  ContainerOperators.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//
import SwiftyJSON


public typealias completionHandler    = (response: ResponseHandler) -> Void
public typealias serializedCompletion = (response: SerializebleObject, success : Bool) -> Void

prefix operator ~{}
infix operator <~>{associativity left precedence 140}

public prefix func ~<T: Resolveable>(resolver: Oatmeal) -> T?
{
    return resolver.get()
}

public prefix func ~(key: String) -> Resolveable?
{
    return Oats().get(key)
}

public prefix func ~<T: SerializebleObject>(json : JSON) -> T?
{
    if let Serializer : Serializer = ~Container.App, model : T =  Serializer.serialize(json)
    {
        return model
    }
    return nil
}

public prefix func ~<T: SerializebleObject>(json : String) -> T? {
    if let Serializer : Serializer = ~Container.App, model : T =  Serializer.serialize(json){
        return model
    }
    return nil
}

//infix operator ~>{ associativity left precedence 140 }
public func ~><T: Resolveable>(inout member: T, container: Oatmeal){
    container.bind(member)
}

public func ~><T: Resolveable>(inout member: T, key: String)
{
    Oats().bind(key, member: member.dynamicType)
}

public func ~><T: Provider>(inout provider: T, container: Oatmeal){
    container.register(provider)
}

public func ~><T: Provider>(inout providers: [T], container: Oatmeal){
    container.register(providers)
}


public func ~><T: Events>(events: T?, eventName: String)
{
    if let events : Events = ~Container.App{
        events.fire(eventName)
    }
}

public func ~><T: SerializebleObject>(inout left: T, json: String)->T?{
    //Models use the same function signature as Resolveables, which can cause confusion when attempting to toss them into the IoC. We fix this by using the protocol method
    if left.bindsToContainer()
    {
        left ~> "\(left.dynamicType)"
    }
    if let model : T = ~json{
        return model
    }
    return nil
}

public func ~><T: SerializebleObject>(var left: T, json: JSON)->T?{
    //Models use the same function signature as Resolveables, which can cause confusion when attempting to toss them into the IoC. We fix this by using the protocol method
    if left.bindsToContainer()
    {
        left ~> "\(left.dynamicType)"
    }
    if let model : T = ~json{
        return model
    }
    return nil
}


/*
   Operator to create a strong reference to the container.
   This will bind an entity to the container without deinitializing.
   Should be used carefully.
*/
public func <~><T: Resolveable>(singleton: T, container: Oatmeal){
   container.bindSingleton(singleton)
}


public func Oats()->Oatmeal
{
    return Container.App
}

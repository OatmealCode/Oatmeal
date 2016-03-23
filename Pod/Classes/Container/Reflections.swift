//
//  Reflections.swift
//  Pods
//
//  Created by Michael Kantor on 12/17/15.
//
//

import Foundation

//Used to store already reflected classes

public class Reflections : Resolveable
{
    public static var entityName : String? = "Reflections"
    
    typealias reflected = [String: properties]
    
    private var mirrors : reflected
    
    public subscript(key : String) -> properties?{
        get{
            return get(key)
        }
        set(newProp)
        {
            if let value = newProp
            {
               set(key,value : value)
            }
        }
    }
    
    
    public required init()
    {
        mirrors  = reflected()
    }
    
    public func get(key:String) -> properties?
    {
        if let mirror = mirrors[key]
        {
            return mirror
        }
        return nil
    }
    
    static func getBundleName(member : Resolveable? = nil) -> String
    {
        var bundleName = NSBundle.mainBundle()
        
        if let m = member as? AnyObject
        {
            bundleName = NSBundle(forClass: m.dynamicType)
        }
        
        let name = String(bundleName.infoDictionary?["CFBundleName"])
        
        return name
            .replace(" ", withString: "_")
            .replace("-", withString: "_")
    }
    
    public func set(key:String, var value : properties)
    {
        let resolutionAttempts      = Property()
        resolutionAttempts.value    = 0
        resolutionAttempts.label    = "resoltionAttempts"
        value["resolutionAttempts"] = resolutionAttempts
        mirrors[key] = value
    }
    
    public func reflect(member:Resolveable) -> properties
    {
        var reflectedProperties   = properties()
        let reflectedMember       = Mirror(reflecting: member)
        
        //First we're going to reflect the type and grab the types of properties
        
        if let  children = AnyRandomAccessCollection(reflectedMember.children)
        {
            
            for (optionalPropertyName, value) in children
            {
                if let name  = optionalPropertyName
                {
                    
                    let propMirror = Mirror(reflecting: value)
                    let type       = Reflections.open(value)
                    let property   = Property(mirror: propMirror, label : name,value : value, type : type)
                    
                    if let (_,optionalValue) = propMirror.children.first  where propMirror.children.count != 0
                    {
                        property.unwrappedOptional = optionalValue
                    }
                    reflectedProperties[name] = property
                }
            }
        }
        self[member.getName()] = reflectedProperties

        return reflectedProperties
    }
    
    class func open(any: Any?) -> Any.Type
    {
        let mi = Mirror(reflecting: any)
        
        if let children = AnyRandomAccessCollection(mi.children)
        {
            if mi.children.count == 0 { return NullElement.self }
            for (_, value) in children
            {
                return value.dynamicType
            }
        }
        
        return mi.subjectType
    }
    
    public func has(key:String)->Bool
    {
        return get(key) != nil
    }
}
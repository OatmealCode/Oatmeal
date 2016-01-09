//
//  Resolveable.swift
//  Pods
//
//  Created by Michael Kantor on 9/14/15.
//
//

import Foundation
import SwiftyJSON

public struct DidResolve
{
    var success : Bool
    var key : String
}

public typealias properties = [String:Property]

public extension Resolveable
{
    
    public var cost: Int
    {
       var c = 0
       let props = toProps()
       for(_,value) in props
       {
        switch(value.value)
        {
         case _ as Int:
            c++
         case _ as Double:
            c++
         case _ as Float:
            c++
         case _ as Int64:
            c += 8
         case _ as Int32:
            c += 4
         case let asString as String:
            c += asString.length
         case let nsString as NSString:
            c += nsString.length
         case  _ as String:
            c++
         default:
             break
        }
       }
        return c
    }
    
    private func updateJson(var jObject: JSON, key:String, prop : Property) -> JSON
    {
        let arrayExpression      = "\\[(.*?)]"
        let dictionaryExpression = "\\[(.*?):(.*?)]"
        let stringProp           = String(prop.value)
        
        if let _ = stringProp[arrayExpression], value = prop.value as? NSArray
        {
            jObject["object"][key].arrayObject = value as [AnyObject]
        }
        else if let _ = stringProp[dictionaryExpression], value = prop.value as? NSDictionary,dict = value as? [String : AnyObject]
        {
            jObject["object"][key].dictionaryObject = dict
        }
        else
        {
            jObject["object"][key] = JSON(stringProp)
        }
        return jObject
    }
    
    public func toJSON() -> JSON
    {
        let props         = toProps()
        var data          = [String:JSON]()
        data["className"] = JSON(self.getName())
        data["object"]    = JSON([String:JSON]())
        var jObject       = JSON(data)
        
        for(key,prop) in props
        {
            var isNil = false
            
            if(prop.mirror.displayStyle == .Optional)
            {
               if let unwrappedValue = prop.unwrappedOptional
               {
                 prop.value = unwrappedValue
               }
               else
               {
                 isNil = true
               }
            }
            if(isNil)
            {
                continue
            }
            
            if let serializable = prop.value as? SerializebleObject
            {
               jObject["object"][key] = JSON(serializable.toJSON().dictionaryValue)
            }
            else
            {
                jObject     =   updateJson(jObject, key: key, prop: prop)
            }
        }
        
        
        return jObject
    }
 
    public func toProps() -> properties
    {
        //If the properties were already parsed, we're just going to fetch them.
        if let reflector : Reflections = ~Oats(),props = reflector.get(getName())
        {
            return props
        }
        let reflectedModel       = Mirror(reflecting: self)
        var reflectedProperties  = properties()
        
        //First we're going to reflect the type and grab the types of properties
        
        if let  children = AnyRandomAccessCollection(reflectedModel.children)
        {
            
            for (optionalPropertyName, value) in children
            {
                if let name  = optionalPropertyName
                {
                
                    let propMirror = Mirror(reflecting: value)
                    let type       = Oats().open(value)
                    let property   = Property(mirror: propMirror, label : name,value : value, type : type)
                    let optionalMirror = Mirror(reflecting: value)
                    
                    if let (_,optionalValue) = optionalMirror.children.first  where optionalMirror.children.count != 0
                    {
                        property.unwrappedOptional = optionalValue
                    }
                    reflectedProperties[name] = property
                }
            }
        }
        return reflectedProperties
    }

    
    public func resolvableFilter(prop: Property) -> DidResolve
    {
        var name  = String(prop.mirror.subjectType)
        
        if(prop.mirror.displayStyle != .Optional)
        {
             let test = prop.value is Resolveable
             return DidResolve(success: test, key: name)
        }
        if let match = name["<(.*?)>"]
        {
            name      = match
            
            name      = name.replace(">",withString: "")
            
            name      = name.replace("<",withString: "")
            
            if Oats().has(name)
            {
                return DidResolve(success: true, key: name)
            }
        }
        return DidResolve(success: false, key: name)
       
    }

    
    public func dependencies(var props : properties = properties()) -> properties
    {
        var entities = properties()
        
        if let reflector  : Reflections = ~Oats()
        {
        
        let name   = getName()
        
        if props.count <= 0
        {
            props = self.toProps()
            reflector[name] = props
        }
        
        for(_,prop) in props
        {
        
            let value : DidResolve = self.resolvableFilter(prop)
            
            if(value.success)
            {
                entities[value.key] = prop
            }
        }
        }
        return entities
    }
    
    public func getName() -> String
    {
        let dynamicName = self.dynamicType
        var name = ""
        if let entityName = dynamicName.entityName{
            name = entityName
        }
        else
        {
            name = String(dynamicName).capitalizedString.replace(".Type",withString: "")
        }
        return name
    }
    
}
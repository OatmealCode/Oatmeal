//
//  Configuration.swift
//  Pods
//
//  Created by Michael Kantor on 8/21/15.
//
// A Place to store configuration

import Foundation


public class Configuration : NSObject,Resolveable
{

    var cache : Cacheable?
    
    public static var entityName :String? = "Configuration"

    public var config : [Setting] = [Setting]()
    
    public var cacheSettingFile = true
    
    required public override init()
    {
        if let cache : FileCache = ~Oats()
        {
            self.cache = cache
        }
        super.init()
        self.set("Settings")
    }
    
    public init(location:String)
    {
        if let cache : FileCache = ~Oats()
        {
            self.cache = cache
        }
        super.init()
        self.set(location)
    }
    
    public subscript(key : String) -> Setting?{
        get{
            return self.find(key)
        }
        set(newProp)
        {
            if let value = newProp
            {
                self.config.append(value)
            }
        }
    }
    
    /**
        - parameter plist: the name of the pList file in the bundle
    **/

    public func set(plistName : String)
    {
        if let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist"), plist = NSDictionary(contentsOfFile: path)
        {
            //Bind the new settings to the Configuration Object
            for(key,value) in plist
            {
                 if let key = key as? String
                 {
                 let newConfig = Setting(name: key,value:value,cached:cacheSettingFile, namespace: plistName)
                 config.append(newConfig)
                 //Cache for configuration will be readonly.
                 if(cacheSettingFile)
                 {
                    self.cache?.set("Setting.\(key)", value: newConfig)
                 }
              }
            }
        }
    }
    
    /**
    - parameter key: The configuration Key
    - parameter value: The object being placed in the config
    - parameter cached: Boolean indicating if the configuration should be cached to avoid later I/O
    **/

    public func set(key:String, value:AnyObject, namespace : String = "", cached: Bool = false)
    {
        let newConfig = Setting(name: key,value:value,cached:cached, namespace : namespace)
        self.config.append(newConfig)
    }
    
    
    /**
    - parameter key: The configuration Key
    - parameter namespace: The namespace the config key might be located in
    **/
    
    public func has(key:String, namespace:String?=nil)->Bool
    {
        return (self.get(key,namespace:namespace) !== nil)
    }
    
    /**
    - parameter key: The configuration Key
    - parameter namespace: The namespace the config key might be located in
    **/
    
    public func get(key:String,namespace:String? = nil) -> AnyObject?
    {
        return self.find(key,namespace:namespace)?.value as? AnyObject
    }

    internal func find(key:String, namespace : String? = nil)->Setting?
    {
        // 1. Check if dot notation is used.
        // 2. if so, split the string into the dictionary search terms.
        if(key.containsString("."))
        {
            var CurrentValue  = [String:AnyObject]()
            var searches      = key.split(".")
            var keyCount      = 1

            guard let TopNode = self.config.find({ $0.name == searches.first})?.value as? [String:AnyObject] else
            {
                return nil
            }
            
               searches.removeFirst()
            
               CurrentValue = TopNode
            
               for term in searches
            {
                if let finalValue = CurrentValue[term] where searches.count <= keyCount
                {
                    return Setting(name:term, value: finalValue)
                }
                
                keyCount++
                    
                guard let nextDict = CurrentValue[term] as? [String:AnyObject] else
                {
                    return nil
                }
                    
                CurrentValue = nextDict
            }
        }
    
        if let namespace = namespace, setting = self.config.find({ $0.name == key && $0.namespace == namespace })
        {
            return setting
        }
        else if let setting = self.config.find({ $0.name == key})
        {
            return setting
        }
        
        /*
            If the current instance of configuration was wiped, we make a last ditch effort to check the cache for the value
        */
        if let log : FileLog = ~Oats()
        {
            log.error("Cached missed for \(key) or MemoryCache not bound to Container")
        }
        
        return nil
    }

}

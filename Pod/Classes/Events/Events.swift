//
// Created by Michael Kantor on 2/13/15.
// Copyright (c) 2015 Michael Kantor, Oatmeal. All rights reserved.
//

import Foundation

//Closure Based Events Bound to the container of the IoC.

 public class Events : Eventable {
    
    private lazy var globalListeners = [String : Event]()
    
    private lazy var localListeners  = [String : Event]()
    
    public static var entityName : String? = "events"
    
    public func all() -> [String : Event]
    {
        return self.globalListeners
    }

    public required init()
    {
        
    }
    
    public subscript(key : String) -> Event?{
        get{
            return get(key)
        }
    }
    
    public func get(key:String) -> Event?
    {
        if let e = globalListeners[key]
        {
            return e
        }
        if let e = localListeners[key]
        {
            let className = getNamespace()
            
            if let name = className where e.namespace == String(name)
            {
                return e
            }
        }
        return nil
    }
    
    public func has(key:String)->Bool
    {
        return get(key) != nil
    }
    
    /*
      Bind a new event to a specific namespace
    */
    public func listenFor(event:String,namespace:String,handler : (event : Event) -> Void)
    {
        let e  = Event(name : event)
        
         e.callback = { (event : Event) -> () in
            e.lastFiredAt = Int(NSDate().timeIntervalSince1970)
            handler(event: e)
        }
        
        e.namespace = namespace
        localListeners[event] = e
    }
    /**
    - parameter event : The name of the event so it can later be fired.
    - parameter global: Defines if the event should be accessible from any part of the application
    - parameter handler : the closure or method that should be executed when the event is fired
    
        Generic method for binding an event to the IoC
    **/
    public func listenFor(event : String, global : Bool = true, handler : (event : Event) -> Void){
        
        let e  = Event(name : event)
        
        e.callback = { (event : Event) -> () in
            e.lastFiredAt = Int(NSDate().timeIntervalSince1970)
            handler(event: e)
        }
        
        //If the directive is not global, then we make the assumption that the event
        //is only to be resolved if the controller is the same as the one the event
        //was created in
        
        if(global)
        {
            globalListeners[event] = e
        }
        //Reflect the currently used controller and gets it objectId
        else if let className = getNamespace()
        {
            e.namespace = String(className)
            localListeners[event] = e
        }
    }
    
    /**
         - parameter event : The name of the event that should be removed from the IoC
    **/
    public func dispose(event : String){
        globalListeners.removeValueForKey(event)
        localListeners.removeValueForKey(event)
    }
    
    public func flush()
    {
        //Loop through the current controllers events & "flush" them
        if let className = getNamespace(){
            for (key,value) in localListeners{
                if className == value.namespace!{
                    localListeners.removeValueForKey(key)
                }
            }
        }
        
    }
    
    public func getNamespace()->String?
    {
        let current              = Controller.getCurrentController()
        let className            = Mirror(reflecting: current).subjectType
        return String(className)
    }
    
    
    public func fire(event : String,
        payload : [String : AnyObject]? = nil) -> (Bool,Event?)
    {
        
        if let e = get(event)
        {
            if let data = payload
            {
               e.data = data
            }
            
            e.handle()
            
            return (true,e)
        }
        #if debug
           print("Event \(event) Does Not Exist.", terminator: "")
        #endif
        
        return (false,nil)
}
    
}
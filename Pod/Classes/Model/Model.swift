//
//  Model.swift
//  Poke
//
//  Created by Michael Kantor on 2/26/15.
//  Copyright (c) 2015 Michael Kantor. All rights reserved.
//

import Foundation


///Define JSON Map to retrieve data 
///Ex 1: "data.users" || "data:users" can be seperated by "." || ":"
///Define collection type from CloudKit

public typealias Prepared = (Model: SerializebleObject) -> Void

public class Model : SerializebleObject,Modelable,Autoresolves{
    
    public var events   : Events?
    // the unique id representing the model
    public var id       : Int?
    public var reloaded : Bool
    public var maxPages : Int
    public var customEntityName : String = "Model.*"
    
    public var route : Route?

    
    public var pages: [Int] = [Int]() {
        willSet(newValue)
        {
            if (!pages.contains(currentPage))
            {
                Model.getCollection()
                if let events = self.events
                {
                    events.fire("modelRetrieved")
                }
            }
        }
        didSet
        {
            pages = $.uniq(pages)
        }
    }
    
    
    public var currentPage: Int = 1 {
        didSet {
            if currentPage <= 0 {
                currentPage = 1
            }
            if currentPage > maxPages {
                currentPage = maxPages
            }
        }
    }
    
    public var totalItems: [Int:Int] = [1: 0]
    
    class func from(route: Routing, prepared: Prepared)
    {
        
    }
    
    /**
       - parameter route : The Route from where to get the data to serialize this model.
    **/
    public class func from<T: SerializebleObject>(route:Route, prepared: (Model: SerializebleObject) -> (), condition : ((object:T) -> Bool)? = nil)
    {
        //Use paremeters as filter keys for CloudKit & Cache
        switch(route.storageType)
        {
           case .Networking:
                if let http : Networking = ~Oats()
                {
                    http.fire(route, completion: { response in
                        if let json = response.response, serialized : T = ~json
                        {
                            if let validate = condition where validate(object: serialized)
                            {
                                prepared(Model: serialized)
                                
                            }
                            else
                            {
                                prepared(Model: serialized)
                            }
                        }
                    })
                }
          case .CloudKit:
            if let cloud : CloudStorage = ~Oats()
            {
                //Return the first model from the cloud that meets the criteria
                cloud.get
                {
                    (response : [T?]) in
                    
                    for models in response{
                        if let model = models, validate = condition where validate(object : model)
                        {
                             prepared(Model: model)
                             return
                        }
                    }
                    
                }
            }
        case .Filesystem:
            if let filesystem : FileStorage = ~Oats()
            {
                if let validate = condition{
                    filesystem.find(validate)
                }
            }
        case .Cache:
            //Possibilities 
            // /users/{1} as KEY
            // dot notation of paremters?
            if let cache : FileCache = ~Oats()
            {
                
            }
        }
        
       
    }
    
    public required init()
    {
        self.reloaded = false
        self.maxPages = 1
        self.customEntityName = "Model.*"
        super.init()
        
        reloadModel()
    }
    
    public func setEvents()
    {
        if let events : Events = ~Oats()
        {
            events.listenFor("requestModel", handler : { (event) in
                self.find("\(self.id)")
            })
        }
        
    }
    
    
    /*
        Essentially these method depend on where your data is hosted.
        Wether you use HTTP, CoreData, SQL, Cache, it won't care.
    */
    public class func getCollection() -> [Modelable]?
    {
        //fatalError("This method must be overriden")
        return [self.init()]
    }
    
    
    public class func find(key:String)->Modelable?
    {
        return Model.find(key)
    }
    
    
    public func find(key: String) -> Modelable?
    {
        //fatalError("This method must be overriden")
        return self.dynamicType.init()
    }
    
    
    public func reloadModel() {
        
        if let reachability : Reachability = ~Oats()
        {
            if(reachability.isAvailable())
            {
                /*
                Async.background(after: 400.0)
                {
                    self.find("\(self.id)")
                    self.reloadModel()
                }
                */
            }
        }
        else
        {
            self.reloadModel()
        }
    }
    
    
}


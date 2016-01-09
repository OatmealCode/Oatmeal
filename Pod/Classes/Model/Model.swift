//
//  Model.swift
//  Poke
//
//  Created by Michael Kantor on 2/26/15.
//  Copyright (c) 2015 Michael Kantor. All rights reserved.
//

import Foundation

public class Model : SerializebleObject,Modelable,Autoresolves{
    
    public var events   : Events?
    // the unique id representing the model
    public var id       : Int?
    public var reloaded : Bool
    public var maxPages : Int
    public var customEntityName : String = "Model.*"
    
    public var route : Route?
    typealias Prepared = (Model: Model) -> Void
    
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
    
    //Default initializer so we can magically set properties
    public required init(data: [String:AnyObject])
    {
        self.reloaded    = false
        self.maxPages    = 1
        super.init()
        for (key,value) in data
        {
            setValue(value, forKey: key)
        }
    }
    
    /**
       - parameter route : The Route from where to get the data to serialize this model.
    **/
    class func from(route:Route, prepared:Prepared)
    {
        if let http : Networking = ~Oats()
        {
            http.fire(route, completion: { response in
                if let json = response.response, serialized : Model = ~json
                {
                    prepared(Model: serialized)
                }
            })
        }
    }
    
    public required init()
    {
        self.reloaded = false
        self.maxPages = 1
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
    
    
    public func find(key:String)->Modelable?
    {
        return Model.find(key)
    }
    
    
    public class func find(key: String) -> Modelable?
    {
        //fatalError("This method must be overriden")
        return self.init()
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


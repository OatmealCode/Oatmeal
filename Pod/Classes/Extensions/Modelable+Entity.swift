import Foundation
/*
    Implements default functionality for any object using the protocol Modelable

public extension Modelable
{
    
    var entityName : String? {
        get{
            return "model.\(self.dynamicType)"
        }
        set(newValue)
        {
            self.entityName = entityName
        }
    }



    public func setEvents()
    {
        if let events : Events = ~Oats()
        {
            events.listenFor("requestModel", handler : { (event) in
                self.getCollection()
            })
        }
        
        reloadModel()
    }
    
    
    /*
        Essentially these method depend on where your data is hosted.
        Wether you use HTTP, CoreData, SQL, Cache, it won't care.
    */
    public func getCollection()
    {
        fatalError("This method must be overriden")
    }
    
    /*
        parameter key : String indicating the id of model
    */
    public func find(key: String) -> [AnyObject]?
    {
        fatalError("This method must be overriden")
    }
    
    
    public func reloadModel() {
        
        if let reachability : Reachability = ~Oats()
        {
            if(reachability.isConnected())
            {
                Async.background(after: 400.0)
                    {
                        self.getCollection()
                        self.reloadModel()
                }
            }
        }
        else
        {
            self.reloadModel()
        }
    }
}
*/
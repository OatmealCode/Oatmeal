import Foundation

/*
    Generic class to be used to send logs to outgoing http servers. Can be extended to implement specific services like Rollbar
*/
public class HttpLog : NSObject,Loggable{

	let networking : Networking    = (~Oats())!
    let config     : Configuration = (~Oats())!
    var route: Route
    var handler : completion?
    
    public static var entityName : String? = "HttpLog"
    
    
    public required override init()
    {
        guard let baseUrl = self.config.get("HTTP_LOG_URL") as? String else {
            self.route = Route(baseUrl: "", endpoint: nil, type: nil)
            super.init()
            return
        }
        self.route      = Route(baseUrl: baseUrl, endpoint: nil, type: nil)
        route.method = .POST
        super.init()
    }
    
    init(url:String)
	{
        //Initilize an empty route so we can send our log information to it later.
        self.route = Route(baseUrl: url, endpoint: nil, type: nil)
        route.method = .POST
        super.init()
	}
    
    init(route:Route)
    {
        self.route = route
    }
    
    public func setCompletion(handler : completion)
    {
        self.handler = handler
    }

	public func success(message:String)
	{
        self.log(message, type: .Success)
	}

    public func success<T:AnyObject>(message:[T])
	{
        var body = ""
        
        message.each({ body += String($0)})
        
        self.log(body,type: .Success)
        
	}

	public func error(message:String)
	{
        self.log(message, type: .Warning)
	}

    public func error<T:AnyObject>(message:[T])
	{
        var body = ""
        
        message.each({ body += String($0)})
        
        self.log(body,type: .Warning)

	}
    
    func log(message : String, type:LogType)
    {
        switch(type)
        {
         case .Success:
             route.parameters = ["type" : "Success", "message" : message]
         case .Warning:
             route.parameters = ["type" : "Warning", "message" : message]
         default:
             break
        }
       
        if let handler = self.handler
        {
            networking.done = handler
        }
        networking.fire(route)
    }
    
    public func didBind()
    {
    
        
    }

    public func didResolve()
    {
        Oats().bindIf({!Oats().has("Configuration")},
            withMember : Configuration.self,
            completion : {}
        )
        Oats().bindIf({!Oats().has("Networking")},
            withMember : Networking.self,
            completion : {}
        )
        
    }
}

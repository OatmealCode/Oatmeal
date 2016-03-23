//
//  Networking.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

public typealias completion  = (response: ResponseHandler) -> Void

public class Networking : NSObject,Resolveable
{
    public static var entityName : String? = "Networking"
    
    public var done  : completion?
    public var error : completion?
    public var baseUrl : String?
    
    public var isConnected : Bool
    {
        return Reachability.isAvailable()
    }
    
    var manager : Alamofire.Manager
    
    public var headers : [String:String]
    
    var pendingRequest : Bool = false
    
    public var requestCap : Int      = 20
    public var currentRequests : Int = 0
    
    
    public required override init()
    {
        self.manager = Alamofire.Manager()
        headers = [String:String]()
    }
    
    public func setHeader(key:String,value:String)
    {
        headers[key] = value
    }
    
    public subscript(key : String) -> String
    {
        get{
            return self.headers[key] ?? ""
        }
        set(newValue)
        {
            self.headers[key] = newValue
        }
    }
    
    func fireAs(method: Alamofire.Method,url:String, type: RequestType? = nil, parameters : [String:String]? = nil, completion:(response: ResponseHandler) -> Void )
    {
        
        let requestType : RequestType = type ?? .ShouldSendUrlAndReturnJson

        // If the URL provided does not start with http or https
        // we want to use the previously set base url so that
        // we can build the url from the provided endpoint.
        var complete = baseUrl ?? ""
        if let _ = url.rangeOfString("^https?://)", options: .RegularExpressionSearch) {
            complete = url
        } else {
            // Ensure we have a protocol
            if !complete.hasPrefix("https://") && !complete.hasPrefix("http://") {
                complete = "http://\(complete)"
            }
            
            // Ensure we don't get double slashes by stripping the last
            // in the base if there is already one provided with the
            // endpoint. This allows users to have slashes anyway.
            if complete.characters.last == "/" && url.characters.first == "/" {
                complete = "\(complete.substringToIndex(complete.endIndex.predecessor()))\(url)"
            }
        }

        var route = Route(method: method, baseUrl: complete, endpoint: nil, type: requestType)
        
        if let params = parameters
        {
            route.parameters = params
        }
        
        return fire(route,completion:completion)
    }
    
    public func fire(route:Route)
    {
        if let onCompleted = self.done
        {
            self.fire(route, completion: onCompleted)
        }
        else
        {
            self.fire(route,completion: { handler in })
        }
    }

    
    public func fire(var route : Route, completion:(response: ResponseHandler) -> Void)
    {
        //Networking is meant as a one track lane, but if the developer puts two cars in the lane, we'll create a fork in the road to let the other in
        if(currentRequests >= requestCap)
        {
            NSThread.sleepForTimeInterval(1)
        }
        if(pendingRequest)
        {            
            if let networking : Networking = ~Oats()
            {
                self.currentRequests++
                networking.fire(route, completion: completion)
            }
        }
        else
        {
        //First we create the context of the request
        //Allowing for the developer to have full control over the request
        self.pendingRequest = true
        
        if let config  = route.customConfiguration
        {
            manager = Alamofire.Manager(configuration: config, serverTrustPolicyManager: nil)
        }
        else
        {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.timeoutIntervalForResource = 600
            config.HTTPAdditionalHeaders      = Manager.defaultHTTPHeaders
            
            manager = Alamofire.Manager(configuration: config, serverTrustPolicyManager: route.sslPolicy)
        }
            
        if(headers.count >= 1)
        {
           route.headers = headers
        }
        
        switch(route.type)
        {
        case .ShouldSendUrlAndReturnJson, .ShouldSendJsonAndReturnIt:
            
            manager.request(route.compose()).responseJSON { result in
                var handler = self.getHandler(result.response,result: result.result)
                handler     = self.adjustToExpectation(route, handler: handler)
                self.pendingRequest = false
                self.currentRequests--
                completion(response: handler)
            }
        case .ShouldSendJsonAndReturnString,.ShouldSendUrlAndReturnString:
            manager.request(route.compose()).responseString{ result in
                var handler = self.getHandler(result.response,result: result.result)
                handler     = self.adjustToExpectation(route, handler: handler)
                self.pendingRequest = false
                 self.currentRequests--
                completion(response: handler)
            }
         }
        }
        }
        
        func adjustToExpectation(route:Route, var handler:ResponseHandler)->ResponseHandler
        {
            switch(route.type)
            {
            case .ShouldSendUrlAndReturnJson, .ShouldSendJsonAndReturnIt:
                //Oh look here, we have no json, lets fix that.
                guard let _ = handler.response else{
                    let msg   = ["data" : ["message" : "No response recieved"]]
                    let json : JSON = JSON(msg)
                    handler.response = json
                    return handler
                }
                
            case .ShouldSendJsonAndReturnString,.ShouldSendUrlAndReturnString:
                
                guard let _ = handler.responseString else{
                    handler.responseString = "No Response recieved"
                    return handler
                }
                
            }
            
            return handler
        }
    
    
    func getHandler(response: NSHTTPURLResponse?,result : Result<String,NSError>)->ResponseHandler
    {
        var handler = ResponseHandler()
        switch result {
        case .Success(let data):
    
            handler.responseString   = data
            handler.success          = true
            
        case .Failure(let error):
            handler.message = "Request failed with error: \(error)"
            handler.error   = error
            
            //handler.responseString =  ("\(NSString(data: error.description, encoding: NSUTF8StringEncoding)!)")
            handler.response       = SwiftyJSON.JSON(error.description)
            handler.success  = false
        }
        handler.headers    = response?.allHeaderFields
        handler.statusCode = response?.statusCode
        
        return handler
    }
    
    func getHandler(response: NSHTTPURLResponse?,result : Result<AnyObject,NSError>)->ResponseHandler
    {
        var handler = ResponseHandler()
        switch result {
        case .Success(let data):
            /* parse your json here with swiftyjson */
            
            handler.response       = SwiftyJSON.JSON(data)
            handler.responseString = String(data)
            handler.headers        = response?.allHeaderFields
            
        case .Failure(let error):
            handler.message = "Request failed with error: \(error)"
            handler.error   = error
            handler.response  = SwiftyJSON.JSON(error.description)
            handler.success = false
        }
        handler.headers    = response?.allHeaderFields
        handler.statusCode = response?.statusCode
        return handler
    }
}


extension Networking
{
    public func GET(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: ResponseHandler) -> Void)
    {
        return fireAs(.GET, url: url, type: type, parameters: parameters,completion: completion)
    }
    
    public func GET<T:SerializebleObject>(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: T, success : Bool) -> Void)
    {
        self.GET(url, type: type, parameters: parameters,completion: {
            handler in
            
            self.serializeResponse(handler , completion: completion)
        })
    }
    
    public func PUT(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: ResponseHandler) -> Void)
    {
        return fireAs(.PUT, url: url, type: type, parameters: parameters,completion: completion)
    }
    
    public func PUT<T:SerializebleObject>(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: T, success : Bool) -> Void)
    {
        self.PUT(url, type: type, parameters: parameters,completion: {
            handler in
            
            self.serializeResponse(handler , completion: completion)
        })
    }
    
    public func POST(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: ResponseHandler) -> Void)
    {
        return fireAs(.PUT, url: url, type: type, parameters: parameters,completion: completion)
    }
    
    public func POST<T:SerializebleObject>(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion : (response: T, success : Bool)-> Void)
    {
        self.POST(url, type: type, parameters: parameters,completion: {
            handler in
            
            self.serializeResponse(handler , completion: completion)
        })
    }
    
    public func DELETE(url:String, type: RequestType? = nil, parameters : [String:String]? = nil,completion:(response: ResponseHandler) -> Void)
    {
        return fireAs(.DELETE, url: url, type: type, parameters: parameters,completion: completion)
    }

    public func DOWNLOAD(image:String,completion:(response: ResponseHandler) -> Void)
    {
        let downloader = ImageDownloader()
        var handler    = ResponseHandler()
        if let url = NSURL(string: image)
        {
            let request    = NSURLRequest(URL:url)
            downloader.downloadImage(URLRequest: request, completion: { result in
                
                handler.image    = result.result.value
                handler.success  = result.result.isSuccess
                completion(response: handler)
            })
        }
    }
    
    func serializeResponse<T:SerializebleObject>(handler : ResponseHandler, completion:(response: T, success : Bool) -> Void)
    {
        if let data = handler.response, model : T = ~data
        {
            completion(response:model, success: true)
        }
        else
        {
            completion (response: T(), success: false)
        }
    }
}
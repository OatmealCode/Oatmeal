//
//  Route.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//

import Foundation
import Alamofire

public struct Route{
 
    let baseUrl : String
    public let endpoint: String?
    public var method : Alamofire.Method
    public var parameters : [String:String]?
    var customConfiguration : NSURLSessionConfiguration?
    var sslPolicy : ServerTrustPolicyManager?
    var type : RequestType
    var URLRequest: NSURLRequest?
    public var headers : [String:String]?
    
    public init(baseUrl:String,endpoint:String? = nil, parameters : [String:String]? = nil,type:RequestType? = nil){
        self.method     = .GET
        self.baseUrl    = baseUrl
        self.endpoint   = endpoint
        self.parameters = parameters
        
        if let kind = type
        {
            self.type = kind
        }
        else
        {
            self.type = RequestType.ShouldSendUrlAndReturnJson
        }
    }
    
    public init(method: Alamofire.Method, baseUrl:String,endpoint:String?,type:RequestType?,parameters : [String:String]? = nil){
        self.method     = method
        self.parameters = parameters
        self.baseUrl    = baseUrl
        self.endpoint   = endpoint
        
        if let kind = type
        {
            self.type = kind
        }
        else{
            self.type = RequestType.ShouldSendUrlAndReturnJson
        }
    }
    
    func compose()->URLRequestConvertible
    {
        var encoding : ParameterEncoding
        
        switch(self.type)
        {
           case RequestType.ShouldSendUrlAndReturnJson,RequestType.ShouldSendUrlAndReturnString:
                encoding = ParameterEncoding.URL
            case RequestType.ShouldSendJsonAndReturnIt,.ShouldSendJsonAndReturnString:
                encoding = ParameterEncoding.JSON
        }
        
        let URL = NSURL(string : self.baseUrl)!
        var mutableURLRequest :  NSMutableURLRequest
        
        if let path = self.endpoint
        {
            mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        }
        else
        {
            mutableURLRequest  = NSMutableURLRequest(URL: URL)
        }
        
        if let headers = self.headers
        {
            for(key,value) in headers
            {
                mutableURLRequest.addValue(value, forHTTPHeaderField: key)
            }
            
        }
        mutableURLRequest.HTTPMethod = method.rawValue
        
        return encoding.encode(mutableURLRequest, parameters: parameters).0
        
    }

}
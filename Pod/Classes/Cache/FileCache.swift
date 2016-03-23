//
//  FileCache.swift
//  Pods
//
//  Created by Michael Kantor on 9/14/15.
//
//

import Foundation
import Carlos
import SwiftyJSON

public class FileCache : NSObject,Cacheable{
    
    public static var entityName : String? = "FileCache"
    
    
    public required override init()
    {
        super.init()
    
    }
    
    /**
       - parameter key: The Cache Key representing the file location
       - returns: the resolved cached object
    **/
    public func get(key: String,completion:(response: ResponseHandler) -> Void)
    {
        let cache   = DiskCacheLevel<String,NSData>()
        let request = cache.get(key)
        var handler = ResponseHandler()
        
        request.onSuccess { value in
            let json = JSON(data: value)
            handler.response = json
            handler.responseString = json.rawString()
            handler.success = true
            completion(response: handler)
        }
        request.onFailure { error in
            handler.success = false
            handler.error   = error
            completion(response: handler)
        }
    }
    
    /**
      - parameter key: The Cache Key
      - parameter value : The object being cached
    **/
    
    public func set<T: Resolveable>(key:String,value:T)
    {
        let json        = value.toJSON()
        let fileCache   = DiskCacheLevel<String, NSData>(capacity: 999999)
        if let asString = json.rawString(), encoded = asString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        {
           fileCache.set(encoded, forKey: key)
        }
    }

    

    
}
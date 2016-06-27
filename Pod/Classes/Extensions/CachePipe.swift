//
//  Pipeable.swift
//  Pods
//
//  Created by Michael Kantor on 8/22/15.
//
//

import Foundation
import SwiftyJSON
import Carlos

public extension Cacheable
{
    public func get<T:SerializebleObject>(key:String,completion:(response: T) -> Void)
    {
        self.get(key, completion: {
            handler in
            
            if let data = handler.response, model : T = ~data["object"]
            {
                completion(response:model)
            }
        })
    }
    /**
     - parameter value : The SerializebleObject to be cached.
         Will cache value using its SerializationKey
     **/
    public func set(value : SerializebleObject)
    {
        self.set(value.serializationKey, value: value)
    }
}


//
//  OatmealServiceProvider.swift
//  Pods
//
//  Created by Michael Kantor on 8/25/15.
//
//

import Foundation
import Oatmeal
import SpriteKit

final class OatmealServiceProvider : ServiceProvider
{
     /*
        This is the default service provider for Oatmeal. 
        Objects removed will not be accessible unless bound later.
     */
    var provides : [Resolveable.Type] = [
        FileCache.self,
        MemoryCache.self,
        Configuration.self,
        FileLog.self,
        Reachability.self,
        Networking.self,
        HttpLog.self,
        Serializer.self,
        Reflections.self,
        Owner.self,
        Github.self,
        Person.self,
        Song.self,
        Album.self
    ]
    
    func registerCustomTypes() -> [Any.Type]
    {
        return [Any.Type]()
    }

}
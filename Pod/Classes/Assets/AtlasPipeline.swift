//
//  AtlasPipeline.swift
//  Pods
//
//  Created by Michael Kantor on 9/17/15.
//
//

import Foundation
import SpriteKit

#if os(OSX)
    import AppKit
#endif
#if os(iOS) || os(tvOS)
    import UIKit
#endif
#if os(watchOS)
    import WatchKit
#endif

public class AtlasPipeline : ProactiveResolveable
{
    public static var entityName : String?  = "AtlasPipeline"
    
    public var atlases : [String:SKTextureAtlas]
    
    public var config : Configuration?
    
    public static var atlas = AtlasPipeline()

	public required init()
	{
        self.atlases    = [String:SKTextureAtlas]()
        if let config : Configuration = ~Oats()
        {
            self.config = config
        }
	}
    
    public subscript(key:String)->SKTextureAtlas?
    {
        get{
            return self.get(key)
        }
        set(newValue)
        {
            if let atlas = newValue
            {
                atlases[key] = atlas
            }
        }
    }

    public func get(atlasNamed:String)->SKTextureAtlas?
    {
        if let atlas = atlases[atlasNamed]
        {
            return atlas
        }
        return nil
    }
    
    /*
        To get easy access to the pipeline, and not to include it as a singleton as defualt we will add it as singleton once it is bound for the first time.
    */
    public func didBind()
    {
        self <~> Oats()
    }
    
    public func didResolve()
    {
        Oats().bindIf({!Oats().has(Configuration.self)},
            withMember : Configuration.self,
            completion : {
             self.config  = (~Oats())
          }
        )
        Oats().bindIf({!Oats().has(ImagePipeline.self)},
            withMember : ImagePipeline.self,
            completion : {}
        )
    }
    
    @available(OSX 10.10,iOS 8.0, tvOS 1, *)
    public func create(atlasNamed : String, withImages : [String:AnyObject]) -> SKTextureAtlas
    {
       let dictionary : [String:AnyObject] = withImages
       let atlas = SKTextureAtlas(dictionary : dictionary)
       self.atlases[atlasNamed] = atlas
       return atlas
    }
}
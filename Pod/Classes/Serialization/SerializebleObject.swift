//
//  SerializeObject.swift
//  Pods
//
//  Created by Michael Kantor on 9/12/15.
//
//

import Foundation

public class SerializebleObject: NSObject,Resolveable, DidSerialize
{
    //Required Init
    public static var entityName : String?
    
    public required override init()
    {
    
    }
    
    public func bindsToContainer()->Bool
    {
        return false
    }
    
    public func didSerialize()
    {
        
    }
    /*
    required public init?(coder aDecoder: NSCoder)
    {
        super.init()
        let properties = toProps()
        for i in properties
        {
            let jValue = i.1.value
            let key    = i.0
            var value : Any? = nil
            switch jValue
            {
            case _ as Int:
                value  = aDecoder.decodeIntegerForKey(key)
            case _ as  Double:
                value  = aDecoder.decodeDoubleForKey(key)
            case _ as AnyObject:
                value  = aDecoder.decodeObjectForKey(key)
            case  _ as CGPoint:
                value  = aDecoder.decodeCGPointForKey(key)
            case _  as CGVector:
                value = aDecoder.decodeCGVectorForKey(key)
            case _  as CGSize:
                value = aDecoder.decodeCGSizeForKey(key)
            default:
                print("something else")
            }
            //setValue(value, forKey: key)
        }
        
    }
    
    public func encodeWithCoder(aCoder: NSCoder)
    {
        let properties = toProps()
        for i in properties
        {
            let jValue = i.1.value
            let key    = i.0
            switch jValue
            {
                case let v as Int:
                    aCoder.encodeInteger(v, forKey: key)
                case let v as Double:
                    aCoder.encodeDouble(v, forKey: key)
                case let v as Int64:
                  aCoder.encodeInt64(v, forKey: key)
                case let v as Int32:
                 aCoder.encodeInt32(v, forKey: key)
                case let v as CGPoint:
                 aCoder.encodeCGPoint(v, forKey: key)
                case let v as CGVector:
                 aCoder.encodeCGVector(v, forKey: key)
                case let v as CGSize:
                 aCoder.encodeCGSize(v, forKey: key)
                case let v as NSData:
                 aCoder.encodeDataObject(v)
                case let v as String:
                    aCoder.encodeObject(v, forKey: key)
                case let v as AnyObject:
                    aCoder.encodeObject(v, forKey: key)
                default:
                    #if debug
                        
                       print("Missed encoding key for \(key) of \(jValue)")
    
                    #endif
            }
        }
    }
    
    */
    public override func setValue(value: AnyObject!, forUndefinedKey key: String)
    {
        
        if let log : FileLog = ~Oats()
        {
            log.error("\nWARNING: The object '\(value.dynamicType)' is not bridgable to ObjectiveC")
        }
    
    }
    
}

//
//  CloudStorage.swift
//  Pods
//
//  Created by Michael Kantor on 1/23/16.
//
//

import Foundation
import CloudKit
import SwiftyJSON


public enum SortDirection{
    case Ascending
    case Dscending
}

public class CloudStorage : Storageable
{
    public static var entityName : String? = "CloudStorage"
    
    private var cloud               : CKContainer
    private var publicAccess        : CKDatabase
    private var privateAccess       : CKDatabase
    
    var zone : CKRecordZoneID?
    
    var sort : [NSSortDescriptor]?
    
    let supportedTypes = ["CKAsset","NSData","NSNumber","CLLocation","CKReference","NSString"]
    
    static let cloudMap = [
        "NSURL" : CKAsset.self
    ]
    
    public required init()
    {
        cloud         = CKContainer.defaultContainer()
        publicAccess  = cloud.publicCloudDatabase
        privateAccess = cloud.privateCloudDatabase
    }
    
    
    public func byZone(zone: CKRecordZoneID)-> CloudStorage
    {
        self.zone = zone
        return self
    }
    
    public func orderBy(key:String, direction:SortDirection)->CloudStorage
    {
        var ascending : Bool
        
        ascending = direction == .Ascending

        sort?.append(NSSortDescriptor(key: key, ascending: ascending))
        return self
    }
    
    public func delete(key:String, completion: completionHandler?)
    {
        var id  : CKRecordID
        
        if let zone = self.zone
        {
            id =  CKRecordID(recordName: key, zoneID: zone)
        }
        else
        {
            id = CKRecordID(recordName: key)
        }
        
        privateAccess.deleteRecordWithID(id, completionHandler: {
            (recordID, error) in
         
            if let c = completion
            {
                var handler = ResponseHandler()
                if error != nil
                {
                    handler.error   = error
                    handler.success = false
                }
                c(response:handler)
            }
       })
    }
    
    public func get<T:SerializebleObject>(type:String,completion:(response: [T?]) -> Void)
    {
        let predicate = NSPredicate(value: true)
        let query     = CKQuery(recordType: type, predicate: predicate)
        
        if let sort = self.sort
        {
            query.sortDescriptors = sort
        }
        
        privateAccess.performQuery(query, inZoneWithID: zone)
        {
              (records, error) in
            
              if let results = records
              {
                let response : [T?] = $.map(results)
                {
                    result in
                    
                    let keys   = result.allKeys()
                    
                    var dict   = [String:AnyObject]()
                    
                    for key in keys
                    {
                        dict[key] = result.objectForKey(key)
                    }
                    
                    let json = JSON(dict)
                    
                    if let object : T = ~json
                    {
                        return object
                    }
                    return nil
                }
                completion(response: response)
              }
        }
    }
    
    public func castToCK(prop:Property) -> Property
    {
        let typeAsString = String(prop.type)
        
        switch(typeAsString)
        {
        case let t where t.containsString("Optional"):
            if let unwrapped = prop.unwrappedOptional
            {
                prop.value  = unwrapped
                prop.type   = Reflections.open(prop.value)
            }
        case let t where t.containsString("NSURL"):
            if let url = prop.value as? NSURL
            {
                prop.value  = CKAsset(fileURL: url)
                prop.type   = CKAsset.self
            }
        case let t where t.containsString("String"):
            if let string = prop.value as? String{
                prop.value  = NSString(string: string)
                prop.type   = NSString.self
            }
        case let t where t.containsString("Int"):
            if let int = prop.value as? Int
            {
                prop.value   = NSNumber(integer: int)
                prop.type    = NSNumber.self
            }
        case let t where t.containsString("Float"):
            if let float = prop.value as? Float
            {
                prop.value  = NSNumber(float: float)
                prop.type   = NSNumber.self
            }
        case let t where t.containsString("Dictionary"):
            if let dictionary = prop.value as? Dictionary<String,AnyObject>
            {
                let nsdict = NSMutableDictionary()
                
                for (k,v) in dictionary
                {
                    nsdict.setValue(v, forKey: k)
                }
            }
        case let t where t.containsString("Array"):
            
            if let array = prop.value as? Array<AnyObject>{
                
                let mtarray = NSMutableArray()
                
                $.each(array)
                {
                  mtarray.addObject($0)
                }
                
                if let result =  mtarray.copy() as? [AnyObject]
                {
                    prop.value = result
                }
                prop.value = mtarray
            }
        default:
            break
        }
        return prop
    }

    public func toCompatibleTypes(var props : properties) -> properties
    {
        for (key,prop) in props
        {
            props[key] = castToCK(prop)
        }
        return props
    }
    
    func recordFrom(type: SerializebleObject, key:String) -> CKRecord
    {
        let type  = type.getName()
        
        var id  : CKRecordID
        
        if let zone = self.zone
        {
            id = CKRecordID(recordName: key, zoneID: zone)
        }
        else
        {
            id = CKRecordID(recordName: key)
        }
        
        return CKRecord(recordType: type,recordID:id)
    }

    public func set(value: SerializebleObject,key:String, completion: completionHandler?)
    {
        let record    = recordFrom(value, key: key)
        let props     = toCompatibleTypes(value.toProps(false))
        var relations = [String:SerializebleObject]()
        
        for(k,v) in props
        {
            //We found a relationship
            if let serializebleObject = v.value as? SerializebleObject
            {
                 let relatedRecord = recordFrom(serializebleObject, key: serializebleObject.getName())
                 let reference     = CKReference(record: relatedRecord, action: CKReferenceAction.DeleteSelf)
                 record.setValue(reference, forKey: k)
                 relations[k] = serializebleObject
            }
            else if let object = v.value as? AnyObject
            {
                record.setValue(object, forKey: k)
            }
        }
        
        publicAccess.saveRecord(record, completionHandler: { (record, error) in
            
            if let c = completion
            {
                var handler     = ResponseHandler()
                handler.error   = error
                handler.success = (handler.error != nil)
                c(response: handler)
            }
            
            for(k,value) in relations
            {
                self.set(value, key: k, completion: nil)
            }
        })
    }
}
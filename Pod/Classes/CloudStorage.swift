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

public enum Database{
    case Public
    case Private
}

public class CloudStorage : Storageable
{
    public static var entityName : String? = "CloudStorage"
    
    private var cloud               : CKContainer
    private var publicAccess        : CKDatabase
    private var privateAccess       : CKDatabase
    public var database : CKDatabase
    
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
        database      = privateAccess
    }
    
    
    public func byZone(zone: CKRecordZoneID)-> CloudStorage
    {
        self.zone = zone
        return self
    }
    
    public func setDB(db:Database)
    {
        if(db == .Public)
        {
            self.database = publicAccess
        }
        else if (db == .Private)
        {
            self.database = privateAccess
        }
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
        
        database.deleteRecordWithID(id, completionHandler: {
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
    
    public func First<T:SerializebleObject>(condition: (object : T) -> Bool,completion:(response: T?) -> Void)
    {
        Where(condition)
        {
            (response : [T?]) in
            
            if let first = response.first
            {
                completion(response: first)
            }
            completion(response:nil)
        }
    }

    
    public func Where<T:SerializebleObject>(condition: (object : T) -> Bool,completion:(response: [T?]) -> Void)
    {
        get()
        {
            (response : [T?]) in
            
            var collection = [T]()
            
            for object in response
            {
                if let model = object
                {
                    if condition(object: model)
                    {
                        collection.append(model)
                    }
                }
            }
            completion(response: collection)
        }
    }
    
    public func get<T:SerializebleObject>(var specifiedName : String? = nil,completion:(response: [T?]) -> Void)
    {
        let predicate = NSPredicate(value: true)
        var name      = ""
        
        if let n = specifiedName
        {
            name = n
        }
        else
        {
            if let entityName = T.entityName
            {
                name = entityName
            }
            else
            {
                name = Oats().getDynamicName(String(T))
            }
        }
        
        let query     = CKQuery(recordType: name, predicate: predicate)
        
        if let sort = self.sort
        {
            query.sortDescriptors = sort
        }
        
        database.performQuery(query, inZoneWithID: zone)
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
    
    
    
     public func update(value: SerializebleObject,key:String, completion: completionHandler?)
    {
        
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
                 let name = serializebleObject.getName()
                 let relatedRecord = recordFrom(serializebleObject, key: name)
                 let reference     = CKReference(record: relatedRecord, action: CKReferenceAction.DeleteSelf)
                 record.setValue(reference, forKey: name)
                 relations[name] = serializebleObject
            }
            else if let object = v.value as? AnyObject
            {
                record.setValue(object, forKey: k)
            }
        }
        
        database.saveRecord(record, completionHandler: { (record, error) in
            
            if let c = completion
            {
                var handler     = ResponseHandler()
                handler.error   = error
                
                if error?.code == 11
                {
                    let saveRecordsOperation = CKModifyRecordsOperation()
                    saveRecordsOperation.recordsToSave = [record!]
                    saveRecordsOperation.savePolicy = .IfServerRecordUnchanged
                    
                    self.database.addOperation(saveRecordsOperation)
                    
                }
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
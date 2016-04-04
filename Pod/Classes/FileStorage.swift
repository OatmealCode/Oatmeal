//
//  FileStorage.swift
//  Pods
//
//  Created by Michael Kantor on 3/25/16.
//
//

import Foundation

public class FileStorage : Storageable{
    
    
    public static var entityName: String? = "FileStorage"
    
    var storage : NSFileManager
    
    
    public required init()
    {
        storage = NSFileManager.defaultManager()
    }
    
    public func set(object : SerializebleObject) -> Bool
    {
        let name    = object.getName()
        let root    = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let folder  = "\(root)/Objects/\(name)"
        let key     = NSDate().timeIntervalSince1970
        var handler = ResponseHandler()
        
        self.createFolder(folder)
        do{
            let json = object.toJSON()
            let data = try json.rawData()
            
            self.storage.createFileAtPath("\(folder)/\(key).json", contents: data, attributes: nil)
        }
        catch(let error as NSError)
        {
            print(error.code)
            if let log : FileLog = ~Oats()
            {
                log.write("Failed to set object \(name) due to : \n \(error.description)")
            }
            return false
        }
        return true
    }
    
    
    public func createFolder(path:String)
    {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(path)
        
       do {
        try self.storage.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
       }
       catch let error as NSError {
           print(error.localizedDescription)
        }
        
    }
    
    public func set()
    {
        
    }
}
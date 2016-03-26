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
    
    public func createFolder(path:String)
    {
        do{
           try self.storage.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
         
            
        }
        catch{
            
        }
        
    }
    
    public func set()
    {
        
    }
}
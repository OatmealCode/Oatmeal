//
//  FileStorage.swift
//  Pods
//
//  Created by Michael Kantor on 3/25/16.
//
//

import Foundation
import SwiftyJSON

public class FileStorage : Storageable{
    
    
    public static var entityName: String? = "FileStorage"
    
    var storage : NSFileManager
    var defaultPath : String
    
    
    public required init()
    {
        storage = NSFileManager()
        defaultPath =  String(NSTemporaryDirectory()) + "/Oatmeal/"
    }
    
    public func get<T:SerializebleObject>()->[T?]
    {
        var models = [T?]()
        let base   = T()
        if let res = base as? Resolveable
        {
        
        let name = res.getName()
            
        if let paths = getPaths("\(defaultPath)/\(name)")
        {
            for path in paths
            {
                    
               if let data  = NSData(contentsOfFile: path), model : T = ~JSON(data : data)
               {
                    models.append(model)
                        
                }
            }
          }
        }
        return models
    }

    
    public func set(object : SerializebleObject) -> Bool
    {
           let name    = object.getName()
            
           let temporaryDirectoryURL = NSTemporaryDirectory() as String
        
           //self.createFolder(temporaryDirectoryURL)
            
            do{
                let json = object.toJSON()
                let data = try json.rawData()
                let root = "\(temporaryDirectoryURL)/Oatmeal/\(name)"
                self.createFolder(NSURL(fileURLWithPath: root))
                
                self.storage.createFileAtPath("\(root)/\(object.serializationKey).json", contents: data, attributes: nil)
            
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
    
    func getPaths(path:String) -> [String]?
    {
        do{
          return try self.storage.contentsOfDirectoryAtPath(path)
        }
        catch
        {
            
        }
        return nil
    }
    
    
    public func createFolder(path:NSURL)
    {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                           .UserDomainMask, true)
        
        var error: NSError?
        do{
           try self.storage.createDirectoryAtURL(path,
                                          withIntermediateDirectories: true, 
                                          attributes: nil)
        }
        catch
        {
            
        }
        
    }
    
    public func set()
    {
        
    }
}
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
        storage     = NSFileManager()
        defaultPath =  String(NSTemporaryDirectory()) + "/Oatmeal/"
    }
    
    public func wipeCache<T:SerializebleObject where T: Resolveable>() -> [T?]
    {
        let base =  T()
        var map  =  [T?]()
        let name =  base.getName()
        
        if let paths = getPaths("\(defaultPath)/\(name)")
        {
            for path in paths
            {
                do
                {
                    let modelLocation = "\(defaultPath)/\(name)/\(path)"
                    if let data       = NSData(contentsOfFile: modelLocation), model : T = ~JSON(data : data)
                    {
                        //Current
                        let dt = NSDate()
                        
                        //Future
                        let mt     = NSDate(timeIntervalSince1970: model.expires)
                        
                        let result = dt.compare(mt)
                        
                        if(result == NSComparisonResult.OrderedDescending)
                        {
                            try self.storage.removeItemAtPath(path)
                        }
                        else
                        {
                            map.append(model)
                        }
                    }
                }
                catch(let error)
                {
                    
                }
            }
        }
        return map
    }
    
    #if(iOS || watchOS || tvOS)
    
    public func write(image:UIImage)
    {
        
    
    }
    
    #endif
    
    public func write(path:String, text: String)
    {
        
        let url = NSURL(fileURLWithPath: path)
        
        do{
            let handle = try NSFileHandle(forUpdatingURL: url)
            
            if let oldText = NSString(data: handle.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
            {
                let replacement = "\(oldText)\(text)"
            
                handle.writeData(replacement.dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        catch(let error)
        {
            print(error)
        }
    }
    
    public func find<T:SerializebleObject where T: Resolveable>(condition : (object:T) -> Bool)->[T]?
    {
        
        if let objects : [T] = self.get()
        {
            var response = [T]()
            
            for object in objects
            {
                if condition(object: object)
                {
                    response.append(object)
                }
            }
            return response
        }
        return nil
    }
    
    
    public func get<T:SerializebleObject where T: Resolveable>()->[T]
    {
        var models   = [T]()
        let base     = T()
        
        let name     = base.getName()
        
        if let paths = getPaths("\(defaultPath)/\(name)")
        {
            for path in paths
            {
               let modelLocation = "\(defaultPath)/\(name)/\(path)"
               if let data  = NSData(contentsOfFile: modelLocation), model : T = ~JSON(data : data)
               {
                    models.append(model)
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
                let root = "\(defaultPath)\(name)"
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
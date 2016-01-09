import Foundation
import SwiftyJSON

public class Serializer : NSObject,Resolveable
{
    public static var entityName :String? = "serializer"
    
    public typealias params         = [String:AnyObject]
    public typealias j              = SwiftyJSON.JSON
    
    public var reflectedProperties : properties = properties()
    public var castable : [Any.Type?] = [Any.Type?]() {
        didSet{
            print(castable,terminator:"\n")
        }
}
    
    static var arrayMap : [String:Any.Type?]  =
    [
        "Optional<Array<String>>" : [String]?.self,
        "Optional<Array<Int>>" : [Int]?.self,
        "Optional<Array<NSString>>" : [NSString]?.self,
        "Optional<Array<Double>>" : [Double]?.self,
        "Optional<Array<Float>>" : [Float]?.self,
        "Array<String>"   : [String].self,
        "Array<NSString>" : [NSString].self,
        "Array<Int>"      : [Int].self,
        "Array<Double>"   : [Double].self,
        "Array<Float>"    : [Float].self,
        "Array<CGPoint>"  : [CGPoint].self,
        "Array<CGRect>"   : [CGRect].self,
        "Array<CGFloat>"  : [CGFloat].self,
    ]
    
    static var dictionaryMap : [String:Any.Type] =
    [
        "Dictionary<String, String>"   : [String:String].self,
        "Dictionary<String, NSString>" : [String:NSString].self,
        "Dictionary<String, Double>"   : [String:Double].self,
        "Dictionary<String, Int>"      : [String:Int].self,
        "Dictionary<String, Float>"    : [String:Float].self,
        "Dictionary<Int, String>"      : [Int:String].self,
        "Dictionary<Int, NSString>"    : [Int:NSString].self,
        "Dictionary<Int, Double>"      : [Int:Double].self,
        "Dictionary<Int, Int>"         : [Int:Int].self,
        "Dictionary<Int, Float>"       : [Int:Float].self,
    ]
    
    static var basicMap : [String:Any.Type] =
    [
        "String" : String.self,
        "Int"    : Int.self,
        "Double" : Double.self,
        "Float"  : Float.self,
        "CGFloat": CGFloat.self,
        "CGPoint": CGPoint.self,
        "CGRect" : CGRect.self,
    ]
    
    //This is really a counter of "how many function calls to parse are you willing to make"
    public var recursiveCalls : Int
    public var recursionLimit : Int
    
    public required override init()
    {
       recursiveCalls = 0
       recursionLimit = 10
    }
    
    class func parse(object : Any)->Resolveable.Type?
    {
        if let _ = object as? MemoryCache
        {
            return MemoryCache.self
        }
        if let _ = object as? FileCache{
            return FileCache.self
        }
        if let _ = object as? Configuration
        {
            return Configuration.self
        }
        if let _ = object as? FileLog
        {
            return FileLog.self
        }
        if let _ = object as? Reachability
        {
            return Reachability.self
        }
        if let _ = object as? Networking
        {
            return Networking.self
        }
        if let _ = object as? HttpLog
        {
            return HttpLog.self
        }
        if let _ = object as? Serializer
        {
            return Serializer.self
        }
        
        return nil
    }
    /*
    
    */
    public func parse(model: SerializebleObject, JSON : j) -> SerializebleObject?
    {
        reflectedProperties = model.toProps()
        if(recursiveCalls <= recursionLimit)
        {
            //Inject any depedencies from the container including submodels.
            //This also is done first to rule them out later when checking for dictionaries which also use the object syntax in json
            for (key,prop) in model.dependencies(reflectedProperties)
            {
                if let resolved = ~key as? NSObject
                {
                    //Now lets check if the dependency we pulled is actually a model too!
                    if let autoresolver = resolved as? SerializebleObject
                    {
                        recursiveCalls++
                        let replaced = parse(autoresolver, JSON: JSON[prop.label])
                        model.setValue(replaced, forKey: prop.label)
                    }
                    else
                    {
                       model.setValue(resolved, forKey: prop.label)
                    }
                    //We already set it lets remove from later loops.
                    reflectedProperties.removeValueForKey(prop.label)
                }
            }
            //Set properties on everything else
            
            for (key,prop) in reflectedProperties
            {
                
                let jValue  = JSON[key]
                cast(jValue, prop: prop)
                if let type = castable.find({prop.type == $0})
                {
                    let typeAsString = String(type).replace("Swift.").replace("Optional").replace(")").replace("(")

                    switch(jValue.type)
                    {
                    case .Number:
                        
                        let assertMirror = Mirror(reflecting: jValue)
                        
                        if(assertMirror.displayStyle != .Optional || typeAsString.containsString("NSNumber"))
                        {
                            model.setValue(jValue.numberValue, forKey: key)
                        }
                        
                    case .String:
                        model.setValue(jValue.stringValue, forKey: key)
                        
                    case .Bool:
                        model.setValue(jValue.boolValue, forKey: key)
                        
                    case .Dictionary:
                        let arguements = typeAsString.words()
                        let keyType    = arguements[1]
                        let valueType  = arguements[2]
                        let dict = dictionaryFrom(keyType, valueType: valueType, json: jValue)
                        model.setValue(dict, forKey: key)
                        
                    case .Array:
                        let arguements  = typeAsString.words()
                        let elementType = arguements[1].replace("<").replace(">").replace("Array").replace("Optional")
                        
                            $.map(Serializer.basicMap)
                            {
                               if($0.0 == elementType)
                               {
                                  let array = self.arrayFrom(elementType, json:jValue)
                                  model.setValue(array, forKey:key)
                               }
                            }
                    default:
                        print("The type is unknown \(jValue.type)")
                        break
                    }
                }
            }
        }
        return model
    }
    
    public func parse<T:SerializebleObject>(JSON: j)->T?
    {
        if let model = parse(T.init(), JSON: JSON) as? T
        {
            //Reset Calls
            recursiveCalls = 0
            return model
        }
        return nil
    }
    
    public func arrayFrom(type:String, json: JSON) -> [AnyObject]
    {
        let array = NSMutableArray()
        
        $.map(json.arrayValue)
        {
            array.addObject($0.rawValue)
        }
        
        if let result =  array.copy() as? [AnyObject]
        {
            return result
        }
        return [AnyObject]()
    }

    
    public func dictionaryFrom(keyType:String, valueType: String, json: JSON) -> AnyObject
    {
        let dict = NSMutableDictionary()
        
        $.map(json.dictionaryValue)
        {
            dict.setValue($0.1.rawValue, forKey: $0.0)
        }
        
        return dict
    }
    
    public func serialize<T:SerializebleObject>(json:params)->T?
    {
        let json = j(json)
        return self.parse(json)
    }
    
    public func serialize<T:SerializebleObject>(json:j)->T?
    {
        return self.parse(json)
    }
    
    public func serialize<T:SerializebleObject>(json:String)->T?
    {
        guard let dataFromString = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else
        {
            return nil
        }
        
        let json = JSON(data: dataFromString)
        return self.parse(json)
    }
    
    
    
    /*
       Will return all the types we can possibly cast the JSON value to.
    */
    func cast(uncasted: JSON, prop: Property) -> [Any.Type?]
    {
        switch(uncasted.type)
        {
          case .String,.Number,.Bool:
           parseNumber(uncasted)
           parseString(uncasted)
          case .Array:
           parseArray(uncasted, prop: prop)
          case .Dictionary:
           parseDictionary(uncasted, prop: prop)
        default:
            break
        }

        return castable
    }
    
    func parseDictionary(uncasted: JSON, prop: Property) -> [Any.Type?]
    {
        let type = String(prop.type)
        $.map(Serializer.dictionaryMap)
        {
            if(type.containsString($0.0))
            {
                self.castable.append($0.1)
            }
        }
        
        return castable
        
    }
   
    func parseArray(uncasted: JSON, prop: Property) -> [Any.Type?]
    {
        let type = String(prop.type)
        $.map(Serializer.arrayMap)
        {
          if(type == $0.0)
          {
             self.castable.append($0.1)
          }
        }
    
        return castable
    }
    
    func parseString(uncasted: JSON) -> [Any.Type?]
    {
        if let _ = uncasted.string
        {
            castable.append(String?.self)
            castable.append(String.self)
            castable.append(NSString.self)
        }
        return castable
    }
    
    func parseNumber(uncasted: JSON) -> [Any.Type?]
    {
        
        if let _ = uncasted.double
        {
            castable.append(open(Double?))
            castable.append(Double.self)
        }
        if let _ = uncasted.float
        {
            castable.append(open(Float?))
            castable.append(Float.self)
        }
        if let _ = uncasted.int16
        {
            castable.append(open(Int16?))
            castable.append(Int16.self)
        }
        if let _ = uncasted.int32
        {
            castable.append(Int32.self)
        }
        if let _ = uncasted.int64
        {
            castable.append(Int64.self)
        }
        if let _ = uncasted.int
        {
            castable.append(Int?.self)
            castable.append(Int.self)
        }
        return castable
    }
    
    func open(any: Any?) -> Any.Type
    {
        return Serializer.open(any)
    }
    
    /*
        Simple class func to get the dynamicType of any object. Can be used recursively
        - parameter : Any
    */
    class func open(any: Any?) -> Any.Type
    {
        return Oats().open(any)
    }
    
}

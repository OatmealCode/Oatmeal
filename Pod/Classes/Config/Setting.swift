import Foundation


public class Setting : Autoresolveable{

	 public var name   : String
	 public var cached : Bool
	//Can even be a Dictionary<KeyType, ValueType>
	 public var value  : Any
    /**
      namespace supports multiple plist files with name collisions
    **/
    public var namespace : String

    init(name:String, value : AnyObject, cached: Bool = false, namespace:String = ""){
        self.name      = name
		self.cached    = cached
        self.value     = value
        self.namespace = namespace
        super.init()
        self.customEntityName = name
	}
    
    init(name:String, value : Any,cached : Bool = false, namespace : String = "")
    {
        self.name      = name
        self.cached    = cached
        self.value     = value
        self.namespace = namespace
        super.init()
        self.customEntityName = name
    }

    public required init()
    {
        self.name = ""
        self.cached = false
        self.value = ""
        self.namespace = "global"
        super.init()
        self.customEntityName = name
    }
    

}

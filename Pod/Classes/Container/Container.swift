import Foundation

public class Container : Oatmeal
{
    public static var entityName : String? = "Container"
    /* 
       The singleton reference to the container itself
    */
    
    static public let App = Container()
    
    
    /* 
       Singletons bound to the app always need a reference
    */
    public var singletons :  [Resolveable] = [
        Events(),Reflections()
    ]
    
    /*
       Lazy members bound to the app do not need a reference, and will be deinitlized 
       whenever they are no longer needed.
    */
    private var members: [String:Resolveable.Type] = [String: Resolveable.Type]() {
        didSet
        {
            #if debug
                print(members, terminator: "\n")
            #endif
        }
    }

    
    public required init()
    {
    
    }
    
    public func didResolve(member : Any)
    {
        if let proactiveMember = member as? ProactiveResolveable
        {
            proactiveMember.didResolve()
        }
        //We're going to ensure that all events are registered as soon as the class is resolved.
        if let eventUser = member as? UsesEvents
        {
            eventUser.setEvents()
        }
        
        if let autoresolver = member as? Autoresolves
        {
            injectDependencies(autoresolver)
        }
    }
    

    /*
       First we will check if the user provided an entityName, if they did, we will use it. Otherwise we will get the name of the class instead.
       If the object autoresolves, then we will check if a custom entityName is provided as autoresolves do not have a static one, and they might be stored as singletons later with custom keys.
    */
    public func get<O : Resolveable>() -> O?
    {
        if(O.resolutionAttempts >= O.maxResolutions)
        {
            print("Member \(O.entityName) exceeded resolution attempts of \(O.resolutionAttempts)")
            
            return nil
        }
        O.resolutionAttempts++
        
        guard let name = O.entityName else
        { 
            let name = getDynamicName(String(O))
            
            return self.get(name) as? O
        }
        if let _ = O.self as? Autoresolves, auto = O() as? Autoresolveable where auto.customEntityName != ""
        {
            return self.get(auto.customEntityName) as? O
        }
        return self.get(name) as? O
    }
    
    /*
      First we will check for a framework bound members because it will be most common
      Second we we will check singletons
    */
    public func get(key:String)->Resolveable?
    {
        if let member = members[key]
        {
            member.resolutionAttempts = 0
            let entity = member.init()
            //The instance method for didResolve will only work with an itialized object
            self.didResolve(entity)
            return entity
        }
        
        if let member = singletons.find({$0.dynamicType.entityName == key})
        {
            //Singletons are always initialized
            self.didResolve(member)
            return member
        }
        else
        {
            return nil
        }
    }
    
    public func has(key:String)-> Bool
    {
        return get(key) != nil
    }

    public func has(key:Resolveable.Type)-> Bool
    {
        if let entityName = key.entityName
        {
            return (get(entityName) != nil)
        }
        let dynamicName = getDynamicName(String(key.init().dynamicType))
        
        return (get(dynamicName) != nil)
    }
    
    
    /*
       This is the "safe" bind method. If the developer makes their class Resolveable, and it has a custom entity name, it would be unlikely for a name collision to occur and for the class not to resolve later on. 
    */
    
    public func bind(key: String,member: Resolveable.Type)
    {
        self.members[key] = member
        
        if let proactiveMember = member as? ProactiveResolveable
        {
            proactiveMember.didBind()
        }
    }
    
    
    public func bind(member: Resolveable)
    {
        //Now that we have both the type and a reference to the class,
        //We can initialize it whenever its needed.
        let entity = member.dynamicType
        
        guard let name = member.dynamicType.entityName else
        {
            let dynamicName = getDynamicName(String(entity))
            self.members[dynamicName] = entity
            return
        }
        self.members[name] = entity
        
        //In case the developer wants to listen for the binding of their class
      
        if let proactiveMember = member as? ProactiveResolveable
        {
            proactiveMember.didBind()
        }
        
    }
    
    public func unbind(member: Resolveable)
    {
        for member in members
        {
            if(member.1 == member.dynamicType)
            {
                self.members.removeValueForKey(member.0)
            }
        }
    }
    
    public func bindSingleton(singleton : Resolveable)
    {
        self.singletons.append(singleton)
    }
    
    public func unbindSingleton(singleton:Resolveable)
    {
        let name = singleton.getName()
        
        for i in 0...singletons.count - 1
        {
            if(singletons[i].getName() == name)
            {
                singletons.removeAtIndex(i)
            }
        }
    }
    
    public func bindIf(condition : () -> Bool, withMember : Resolveable.Type,completion : () -> ())
    {
        if(condition())
        {
            let entity = withMember.init()
            bind(entity)
            completion()
        }
    }
    
    public func register(providers  : [ServiceProvider])
    {
        for i in providers
        {
            register(i)
        }
    }
    
    public func getDynamicName(name:String) -> String
    {
        return name.capitalizedString.replace(".Type",withString: "")
    }
    
    public func register(provider: ServiceProvider)
    {
        for i in provider.provides
        {
            if let entityName = i.entityName
            {
                members[entityName] = i
            }
            else
            {
                let name = getDynamicName(String(i.dynamicType))
                members[name] = i
            }
        }

    }
    
    public func injectDependencies(obj: Autoresolves)
    {
        for (key,prop) in obj.dependencies()
        {
            if let autoresolvable = obj as? Autoresolveable, resolved = ~key as? NSObject
            {
                autoresolvable.setValue(resolved, forKey: prop.label)
            }
        }
    }
    

}

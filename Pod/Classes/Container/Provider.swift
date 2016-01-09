import Foundation

public class Provider : ServiceProvider
{
    public var provides : [Resolveable.Type] = [Resolveable.Type]()
    
    
    public init(){
        
    }
    
    public func append(newMember : Resolveable.Type)
    {
        self.provides.append(newMember)
    }
    
    public func register()
    {
        Oats().register(self)
    }
    
    public func registerCustomTypes() -> [Any.Type]
    {
        return [Any.Type]()
    }

}
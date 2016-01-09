import Foundation
import Oatmeal

class Github:SerializebleObject
{
    var name   :String?
    var language : String?
    var owner : Owner?
    var cache : MemoryCache?
    var log  : FileLog?

    
    required init()
    {
        super.init()
    }

    
}
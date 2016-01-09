//
//  Modelable .swift
//  Pods
//
//  Created by Michael Kantor on 8/30/15.
//
//

import Foundation


public protocol Modelable : Resolveable,NSObjectProtocol
{

    var id : Int? { get set}
    
    var reloaded:Bool {get set}

    var maxPages : Int {get set}

    var pages : [Int] {get set}

    var currentPage : Int {get set}

    var totalItems : [Int:Int] { get set}
    
    init(data: [String:AnyObject])
    
    /**
    - parameter value: The Value being set on the Model
    - parameter key : The name of the variable on the model being set
    **/
    func setValue(value: AnyObject?, forKey key: String)
    
    /*
    
    */
    func setEvents()
    
    static func getCollection() -> [Modelable]?

    /**
    - parameter key: String that represents the current number, Ussually a UUID for an External API
     **/
    func find(key:String) -> Modelable?

    /*
        Should be implemented in order to allow for hydration of the model
        in real time    
     */
    func reloadModel()

}

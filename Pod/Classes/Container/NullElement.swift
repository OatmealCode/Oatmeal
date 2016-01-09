//
//  NullElement.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//

import Foundation


public struct NullElement{
    
    var description : String
    var error : String
    
    init(description:String, error:String)
    {
        self.description = description
        self.error       = error
    }
}

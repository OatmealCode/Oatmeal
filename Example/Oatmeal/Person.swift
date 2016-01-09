//
//  Person.swift
//  Oatmeal
//
//  Created by Michael Kantor on 1/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Oatmeal

class Person : Autoresolveable, UsesEvents
{
    var networking : Networking?
    var serializer : Serializer?
    var events : Events?
    
    var swag = [String]()
    var donuts = [Int]()
    var optionalSwag : [String]?
    var optionalInts : [Int]?
    var oranges = [String:String]()
    
    required init()
    {
        super.init()
        self.customEntityName = "Person"
    }
    
    func setEvents() {
        
    }
    
}
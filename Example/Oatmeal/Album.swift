//
//  Album.swift
//  Oatmeal
//
//  Created by Michael Kantor on 1/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Oatmeal

class Album : SerializebleObject{
    var name : String?
    var href : String?
    var available_markets : [String]
    
    required init()
    {
        self.available_markets = [String]()
    }
}
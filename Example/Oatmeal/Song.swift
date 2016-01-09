//
//  Album.swift
//  Oatmeal
//
//  Created by Michael Kantor on 1/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Oatmeal

class Song : SerializebleObject{
    var name : String?
    var href : String?
    var album : Album?
    
    required init()
    {

    }
}
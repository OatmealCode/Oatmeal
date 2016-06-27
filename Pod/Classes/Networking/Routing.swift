//
//  Routing.swift
//  Pods
//
//  Created by Michael Kantor on 5/29/16.
//
//

import Foundation
import Alamofire

public protocol Routing{
    
    var route : Route { get }
    var method : Alamofire.Method { get }
}
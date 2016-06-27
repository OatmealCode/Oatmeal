//
//  Router.swift
//  Oatmeal
//
//  Created by Michael Kantor on 5/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Oatmeal
import Alamofire


enum Router : Routing
{
    
    static let baseUrl   = "https://api.github.com"
    
    case GetFramework(framework: String)
    
    
    var method : Alamofire.Method{
        switch self{
        case GetFramework:
            return .GET
        }
    }
    
    var route : Route{
        
        var route : Route
        let parameters = [String:String]()
        var endpoint   = ""
        
        switch self{
            case .GetFramework(let framework):
                
                endpoint += "/repos/\(framework)"
            
        }
        
        route = Route(baseUrl: Router.baseUrl, endpoint: endpoint, parameters: parameters)
        route.method = method
        
        return route
    }
    
}
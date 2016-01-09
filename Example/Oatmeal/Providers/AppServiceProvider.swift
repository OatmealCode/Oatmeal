//
//  AppServiceProvider.swift
//  Oatmeal
//
//  Created by Michael Kantor on 8/25/15.
//  Copyright © 2015 CocoaPods. All rights reserved.

import Foundation
import Oatmeal

final class AppServiceProvider : ServiceProvider{
    
    var provides : [Resolveable.Type] = []
    
    func registerCustomTypes() -> [Any.Type] {
        return [String.self]
    }
    
}
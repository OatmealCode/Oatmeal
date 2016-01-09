//
//  ServiceProvider.swift
//  Pods
//
//  Created by Michael Kantor on 8/25/15.
//
//

import Foundation

public protocol ServiceProvider
{
    var provides : [Resolveable.Type] { get set}
    /*
       Use this method to add custom types to the IoC so it can recognize them
       moving forward...
    */
    func registerCustomTypes () -> [Any.Type]
}
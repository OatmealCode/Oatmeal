//
//  ProactiveResolvable.swift
//  Pods
//
//  Created by Michael Kantor on 8/24/15.
//
//

import Foundation


public protocol ProactiveResolveable : Resolveable{
    func didBind()
    func didResolve()
}
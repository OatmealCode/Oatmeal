//
//  Controller.swift
//  Poke
//
//  Created by Michael Kantor on 2/25/15.
//  Copyright (c) 2015 Poke Ninja. All rights reserved.
//


import Foundation

#if os(iOS) || os(tvOS)
   import UIKit
#endif

#if os(OSX)
    import Cocoa
    import AppKit
#endif

public class Controller{
    
    
    #if os(iOS) || os(tvOS)
    class func getCurrentController() -> UIViewController
    {
        var current  = UIApplication.sharedApplication().keyWindow!.rootViewController!
        if let c = current.presentedViewController {
            current = c
        }
        if let q = current as? UINavigationController, first = q.viewControllers.first{
            current = first
            print("IS NAV..")
            _  = q.viewControllers[0]
            current = q.viewControllers.first! 
        }
        return current
    }
    
    class func getNavigationController() -> UINavigationController?{
        let current =  UIApplication.sharedApplication().keyWindow!.rootViewController!
        if let q = current as? UINavigationController{
            return q
        }
        print("No navigation controller found..")
        return nil
    }
    #endif
    
    #if os(OSX)
    
    class func getCurrentController() -> NSViewController?
    {
        return NSViewController()
    }
    
    class func getNavigationController() -> NSWindow?
    {
        return NSWindow()
    }
    #endif
}
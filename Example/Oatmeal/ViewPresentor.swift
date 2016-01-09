//
//  ViewPresentor.swift
//  Oatmeal
//
//  Created by Michael Kantor on 8/24/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Oatmeal

class ViewPresentor : ProactiveResolveable
{
    
    static var entityName  : String? = "viewpresentor"
    var cache : MemoryCache?
    
    required init()
    {
        
    }
    
    func render(controller : ViewsController)
    {
        UIView.animateWithDuration(5.5, delay: 1.0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                controller.Hello.textColor       = UIColor.whiteColor()
                controller.Hello.alpha           = 0
                controller.view.backgroundColor  = UIColor.blueColor()
            },completion: nil)
        
         UIView.animateWithDuration(5.5, delay: 2.0, options: UIViewAnimationOptions.CurveLinear,animations: {
            let image = UIImage(named: "oatmeal")
            let imageView = UIImageView(image: image!)
            let frame = controller.view.frame
            imageView.frame = CGRect(x: frame.midX, y: frame.midY + 100, width: 100, height: 100)
            controller.helloOatmeal.alpha = 0
            controller.view.addSubview(imageView)
            controller.view.addSubview(controller.Hello)
            controller.view.layoutIfNeeded()
            },completion: {
                (value: Bool) in
                
                if let events : Events = ~Oats()
                {
                    events.fire("presented")
                }
         })
        
    }
    
    func didBind()
    {
        print("Did Resolve")
        if let events : Events = ~Oats()
        {
            events.listenFor("sayHello", global: true, handler: {
                event in
                
                if let data = event.data, view = data["view"] as? ViewsController
                {
                    self.render(view)
                }
            })
            
            events.listenFor("setText", global: true, handler: {
                event in
                
                if let data = event.data, view = data["view"] as? ViewsController, framework = data["framework"] as? Github, name = framework.name
                {
                    print("Got here 2")
                    view.Hello.text  = "And then there was \(name)"
                    view.Hello.alpha = 1
                }
                
                if let github : Github = ~Oats()
                {
                    print(github.name)
                }
            })
        }
    }

    
    func didResolve()
    {
       
    }
}


//
//  ViewController.swift
//  Oatmeal
//
//  Created by mikenolimits on 08/21/2015.
//  Copyright (c) 2015 mikenolimits. All rights reserved.
//

import UIKit
import Oatmeal
import Foundation

class ViewsController: UIViewController
{

    @IBOutlet weak var Hello: UILabel!
    
    @IBOutlet weak var helloOatmeal: UIButton!
    
    @IBAction func bringTheOats(sender: AnyObject)
    {
        if let events : Events = ~Oats()
        {
            events.fire("sayHello", payload: ["view" : self])
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let s = Github()
        
        s <~> Oats()
        
        Oats().unbindSingleton(s)
        
        
        self.setEvents()
        self.checkDependencies()
        
        
        if let config : Configuration = ~Oats(), players = config.get("GameParams.Players") as? [String:AnyObject]
        {
            print(players["Snake"])
        }
    
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setEvents()
    {
        if let events : Events = ~Oats(), http: Networking = ~Oats()
        {
            print("Listening for presented...")
            events.listenFor("presented", global: true, handler: {
                event in
                
                 self.request(http)
            })
        }
    }
    
    func request(http : Networking)
    {
        http.GET("https://api.spotify.com/v1/tracks/0eGsygTp906u18L0Oimnem", completion: {
            (song : Song, success) in
            song.href = "http://google.com"
            if let cloud : CloudStorage = ~Oats()
            {
                cloud.set(song, key: song.name!)
                {
                    response in
                    
                }
            }
           
        })
    
        http.GET("https://api.github.com/repos/OatmealCode/Oatmeal", completion:  {
              (response:Github,success) in
            
              print(response.name)
        })
        
    }
    
    func checkDependencies()
    {
        guard let _ : ViewPresentor = ~Oats() else
        {
            var presentor = ViewPresentor()
            presentor ~> Oats()
            return
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


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
        
        let github = Github()
        github.name = "Oatmeal"
        github.watchers_count = NSNumber(int : 20)
        let fileStorage = FileStorage()

        fileStorage.set(github)
        
        self.setEvents()
        self.checkDependencies()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setEvents()
    {
        if let events : Events = ~Oats(), http: Networking = ~Oats() where http.isConnected
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
        //Multiple examples of serialization from Networking -> Model -> Cache -> Model
        http.GET("https://api.spotify.com/v1/tracks/0eGsygTp906u18L0Oimnem", completion: {
            (song : Song, success) in
            
            
            if let cache : FileCache = ~Oats()
            {
                cache.set("song",value: song)
                cache.get("song", completion:  {
                    handler in
                    
                    if let json = handler.response
                    {
                        let MrBrightside = json["object"]
                        let albumData    = json["object"]["album"]["object"].dictionaryValue
                        let song = Song()
                        let album = Album()
                        song.name = MrBrightside["name"].stringValue
                        song.href = MrBrightside["href"].stringValue
                        album.name = albumData["name"]?.stringValue
                        album.href = albumData["href"]?.stringValue
                        if let markets = albumData["available_markets"]?.arrayValue
                        {
                            var available_markets = [String]()
                            for i in markets
                            {
                                available_markets.append(i.stringValue)
                            }
                            album.available_markets = available_markets
                        }
                        print(album)
                    }
                    
                })
            }
        })
        
        http.GET("https://api.github.com/repos/OatmealCode/Oatmeal", completion:  {
            (response:Github,success) in
            
            if let events : Events = ~Oats()
            {
                events.fire("setText",payload: ["view":self, "framework" : response])
            }
            
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

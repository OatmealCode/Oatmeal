//
//  Reachability.swift
//  Swift-Reachability
//
//  Created by Isuru Nanayakkara on 9/2/14.
//  Copyright (c) 2014 Isuru Nanayakkara. All rights reserved.
//

import Foundation
import SystemConfiguration


public class Reachability : Resolveable {
    
    var connected : Bool = true{
        didSet{
            print("There is Internet : \(connected)")
        }
    }
    public static var entityName :String? = "reachability"

    enum ReachabilityType {
        case WWAN,
        WiFi,
        NotConnected
    }
    
    public required init()
    {
        
    }
    
    public func connectedToNetwork() -> Bool
    {
        return Reachability.connectedToNetwork()
    }
    
    //Copy paste of below
    //http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    
    class func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable     = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    class func isAvailable() -> Bool{
        return connectedToNetwork()
    }
    
    public func isAvailable() -> Bool{
        return connectedToNetwork()
    }
    
}

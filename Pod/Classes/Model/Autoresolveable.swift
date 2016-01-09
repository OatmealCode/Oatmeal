//
//  Autoresolveable.swift
//  Pods
//
//  Created by Michael Kantor on 1/4/16.
//
//

import Foundation

public class Autoresolveable : SerializebleObject,Autoresolves
{
   public var customEntityName = "Autoresolves.*"
   public required init()
   {
     super.init()
   }
    
}
//
//  Property.swift
//  Pods
//
//  Created by Michael Kantor on 9/12/15.
//
//

import Foundation


public class Property : SerializebleObject
{
    public var mirror : Mirror
    public var label  : String
    public var value  : Any
    public var type   : Any.Type
    public var unwrappedOptional : Any?
    
    init(mirror: Mirror, label : String,value : Any, type : Any.Type)
    {
        self.mirror = mirror
        self.label  = label
        self.value  = value
        self.type   = type
        super.init()
    }

    public required init()
    {
        self.mirror  = Mirror(reflecting : "emptyValue")
        self.label   = "emptyMirror"
        self.value   = "emptyValue"
        self.type    =  String.self
        super.init()
    }
}
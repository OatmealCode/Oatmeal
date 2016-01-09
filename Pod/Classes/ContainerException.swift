//
//  MemberNotFound.swift
//  Pods
//
//  Created by Michael Kantor on 8/23/15.
//
//

import Foundation

public enum ContainerException{
    
    case DoesntExist(key:String)
    case InvalidType(member:Any)
    
    var key : String {
        switch self{
        case .DoesntExist(let key):
            return key
        case .InvalidType(let member):
            return String(member)
        }
    }
    

    var err : String
    {
        switch self{
          case .DoesntExist(let key):
              return "Member of name \(key) does not exist in the container"
          case .InvalidType(let member):
             let name = String(member)
             return "Member of type \(name) does not exist in the container"
      }
    }
    
    
}
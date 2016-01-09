//
//  Int.swift
//  Cent
//
//  Created by Ankur Patel on 6/30/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CalendarMath {
    private let unit: NSCalendarUnit
    private let value: Int
    private var calendar: NSCalendar {
        return NSCalendar.autoupdatingCurrentCalendar()
    }
    
    public init(unit: NSCalendarUnit, value: Int) {
        self.unit = unit
        self.value = value
    }
    
    private func generateComponents(modifer: (Int) -> (Int) = (+)) -> NSDateComponents {
        let components = NSDateComponents()
        components.setValue(modifer(value), forComponent: unit)
        return components
    }
    
    internal func from(date: NSDate) -> NSDate? {
        return calendar.dateByAddingComponents(generateComponents(), toDate: date, options: [])
    }
    
    internal var fromNow: NSDate? {
        return from(NSDate())
    }
    
  internal func before(date: NSDate) -> NSDate? {
        return calendar.dateByAddingComponents(generateComponents(-), toDate: date, options: [])
    }
    
    internal var ago: NSDate? {
        return before(NSDate())
    }
}

public extension Int {
    
    

    /// Check if it is even
    ///
    /// :return Bool whether int is even
    public var isEven: Bool {
        get {
            return self % 2 == 0
        }
    }

    /// Check if it is odd
    ///
    /// :return Bool whether int is odd
    public var isOdd: Bool {
        get {
            return self % 2 == 1
        }
    }

    /// Get ASCII character from integer
    ///
    /// :return Character represented for the given integer
    public var char: Character {
        get {
            return Character(UnicodeScalar(self))
        }
    }

    /// Get the next int
    ///
    /// :return next int
    public func next() -> Int {
        return self + 1
    }
    
    /// Get the previous int
    ///
    /// :return previous int
    public func prev() -> Int {
        return self - 1
    }

    
    /// Invoke the callback from int down to and including limit
    ///
    /// :params limit the min value to iterate upto
    /// :params callback to invoke
    public func downTo(limit: Int, callback: () -> ()) {
        var selfCopy = self
        while selfCopy-- >= limit {
            callback()
        }
    }
    
    /// Invoke the callback from int down to and including limit passing the index
    ///
    /// :params limit the min value to iterate upto
    /// :params callback to invoke
    public func downTo(limit: Int, callback: (Int) -> ()) {
        var selfCopy = self
        while selfCopy >= limit {
            callback(selfCopy--)
        }
    }

    /// GCD metod return greatest common denominator with number passed
    ///
    /// :param number
    /// :return Greatest common denominator
    public func gcd(n: Int) -> Int {
        return $.gcd(self, n)
    }

    /// LCM method return least common multiple with number passed
    ///
    /// :param number
    /// :return Least common multiple
    public func lcm(n: Int) -> Int {
        return $.lcm(self, n)
    }

    /// Returns random number from 0 upto but not including value of integer
    ///
    /// :return Random number
    public func random() -> Int {
        return $.random(self)
    }

    /// Returns Factorial of integer
    ///
    /// :return factorial
    public func factorial() -> Int {
        return $.factorial(self)
    }

    /// Returns true if i is in closed interval
    ///
    /// :param i to check if it is in interval
    /// :param interval to check in
    /// :return true if it is in interval otherwise false
    public func isIn(interval: ClosedInterval<Int>) -> Bool {
        return $.it(self, isIn: interval)
    }

    /// Returns true if i is in half open interval
    ///
    /// :param i to check if it is in interval
    /// :param interval to check in
    /// :return true if it is in interval otherwise false
    public func isIn(interval: HalfOpenInterval<Int>) -> Bool {
        return $.it(self, isIn: interval)
    }

    /// Returns true if i is in range
    ///
    /// :param i to check if it is in range
    /// :param interval to check in
    /// :return true if it is in interval otherwise false
    public func isIn(interval: Range<Int>) -> Bool {
        return $.it(self, isIn: interval)
    }
  
}


extension Int : Resolveable
{
    public static var entityName : String? = "Int"
    
}
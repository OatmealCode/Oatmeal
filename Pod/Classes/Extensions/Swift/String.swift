//
//  String.swift
//  Cent
//
//  Created by Ankur Patel on 6/30/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation


public extension String {
    
     var length: Int {
        get {
            return self.characters.count
        }
    }
  
     var camelCase: String {
        get {
            return self.deburr().words().reduceWithIndex("") { (result, index, word) -> String in
                let lowered = word.lowercaseString
                return result + (index > 0 ? lowered.capitalizedString : lowered)
            }
        }
    }
  
     var kebabCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? "-" : "") + word.lowercaseString
            })
        }
    }
  
     var snakeCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? "_" : "") + word.lowercaseString
            })
        }
    }
  
     var startCase: String {
        get {
            return self.deburr().words().reduceWithIndex("", combine: { (result, index, word) -> String in
                return result + (index > 0 ? " " : "") + word.capitalizedString
            })
        }
    }
  
    /// Get character at a subscript
    ///
    /// :param i Index for which the character is returned
    /// :return Character at index i
     subscript(i: Int) -> Character? {
        if let char = Array(self.characters).get(i) {
            return char
        }
        return .None
    }

    /// Get character at a subscript
    ///
    /// :param i Index for which the character is returned
    /// :return Character at index i
     subscript(pattern: String) -> String? {
        if let range = Regex(pattern: pattern).rangeOfFirstMatch(self).toRange() {
            return self[range]
        }
        return .None
    }

    /// Get substring using subscript notation and by passing a range
    ///
    /// :param range The range from which to start and end the substring
    /// :return Substring
     subscript(range: Range<Int>) -> String {
        let start = startIndex.advancedBy(range.startIndex)
        let end = startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(Range(start: start, end: end))
    }
    
    /// Get the start index of Character
    ///
    /// :return start index of .None if not found
     func indexOf(char: Character) -> Int? {
        return self.indexOf(char.description)
    }
    
    /// Get the start index of string
    ///
    /// :return start index of .None if not found
     func indexOf(str: String) -> Int? {
        return self.indexOfRegex(Regex.escapeStr(str))
    }
    
    /// Get the start index of regex pattern
    ///
    /// :return start index of .None if not found
     func indexOfRegex(pattern: String) -> Int? {
        if let range = Regex(pattern: pattern).rangeOfFirstMatch(self).toRange() {
            return range.startIndex
        }
        return .None
    }
    
    /// Get an array from string split using the delimiter character
    ///
    /// :return Array of strings after spliting
     func split(delimiter: Character) -> [String] {
        return self.componentsSeparatedByString(String(delimiter))
    }

    /// Remove leading whitespace characters
    ///
    /// :return String without leading whitespace
     func lstrip() -> String {
        return self["[^\\s]+.*$"]!
    }
    
    /// Remove trailing whitespace characters
    ///
    /// :return String without trailing whitespace
     func rstrip() -> String {
        return self["^.*[^\\s]+"]!
    }

    /// Remove leading and trailing whitespace characters
    ///
    /// :return String without leading or trailing whitespace
     func strip() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }
}

public extension String {
  
    /// Split string into array of 'words'
    func words() -> [String] {
        let hasComplexWordRegex = try! NSRegularExpression(pattern: RegexHelper.hasComplexWord, options: [])
        let wordRange = NSMakeRange(0, self.characters.count)
        let hasComplexWord = hasComplexWordRegex.rangeOfFirstMatchInString(self, options: [], range: wordRange)
        let wordPattern = hasComplexWord.length > 0 ? RegexHelper.complexWord : RegexHelper.basicWord
        let wordRegex = try! NSRegularExpression(pattern: wordPattern, options: [])
        let matches = wordRegex.matchesInString(self, options: [], range: wordRange)
        let words = matches.map { (result: NSTextCheckingResult) -> String in
            if let range = self.rangeFromNSRange(result.range) {
                return self.substringWithRange(range)
            } else {
                return ""
            }
        }
        return words
    }
  
    /// Strip string of accents and diacritics
    func deburr() -> String {
        let mutString = NSMutableString(string: self)
        CFStringTransform(mutString, nil, kCFStringTransformStripCombiningMarks, false)
        return mutString as String
    }
  
    /// Converts an NSRange to a Swift friendly Range supporting Unicode
    ///
    /// :param nsRange the NSRange to be converted
    /// :return A corresponding Range if possible
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        } else {
            return nil
        }
    }
    
    func replace(target: String, withString: String = "", literal: Bool = false) -> String
    {
        if(literal)
        
        {
            return self.stringByReplacingOccurrencesOfString(target, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        return self.stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    
    func toDictionary() -> [String:AnyObject]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Could not serialize \(self) to dictionary")
            }
        }
        return nil
    }
  
}

extension String : Resolveable
{
    public static var entityName : String? = "String"
}

public extension Character {

    /// Get int representation of character
    ///
    /// :return UInt32 that represents the given character
     var ord: UInt32 {
        get {
            let desc = self.description
            return desc.unicodeScalars[desc.unicodeScalars.startIndex].value
        }
    }

    /// Convert character to string
    ///
    /// :return String representation of character
     var description: String {
        get {
            return String(self)
        }
    }
}

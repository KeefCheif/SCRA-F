//
//  GameInfo.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/23/22.
//

import Foundation

struct GameInfo {
    
    static let DEFAULT_BOARD: [String] = [
        "tw", "blank", "blank", "dl", "blank", "blank", "blank", "tw", "blank", "blank", "blank", "dl", "blank", "blank", "tw",
        "blank", "dw", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "dw", "blank",
        "blank", "blank", "dw", "blank", "blank", "blank", "dl", "blank", "dl", "blank", "blank", "blank", "dw", "blank", "blank",
        "dl", "blank", "blank", "dw", "blank", "blank", "blank", "dl", "blank", "blank", "blank", "dw", "blank", "blank", "dl",
        "blank", "blank", "blank", "blank", "dw", "blank", "blank", "blank", "blank", "blank", "dw", "blank", "blank", "blank", "blank",
        "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank",
        "blank", "blank", "dl", "blank", "blank", "blank", "dl", "blank", "dl", "blank", "blank", "blank", "dl", "blank", "blank",
        "tw", "blank", "blank", "dl", "blank", "blank", "blank", "center", "blank", "blank", "blank", "dl", "blank", "blank", "tw",
        "blank", "blank", "dl", "blank", "blank", "blank", "dl", "blank", "dl", "blank", "blank", "blank", "dl", "blank", "blank",
        "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank",
        "blank", "blank", "blank", "blank", "dw", "blank", "blank", "blank", "blank", "blank", "dw", "blank", "blank", "blank", "blank",
        "dl", "blank", "blank", "dw", "blank", "blank", "blank", "dl", "blank", "blank", "blank", "dw", "blank", "blank", "dl",
        "blank", "blank", "dw", "blank", "blank", "blank", "dl", "blank", "dl", "blank", "blank", "blank", "dw", "blank", "blank",
        "blank", "dw", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "tl", "blank", "blank", "blank", "dw", "blank",
        "tw", "blank", "blank", "dl", "blank", "blank", "blank", "tw", "blank", "blank", "blank", "dl", "blank", "blank", "tw"
    ]
    
    static let BOOSTLESS_BOARD: [String] = [
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank",
        "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank", "blank"
    ]
    
    static let DEFAULT_LETTER_AMOUNTS: [Int] = [9, 2, 2, 4, 12, 2, 3, 2, 9, 1, 1, 4, 2, 6, 8, 2, 1, 6, 4, 6, 4, 2, 2, 1, 2, 1, 2]
    
    static let DEFAULT_LETTER_VALUES: [String: Int] = ["a":1, "b":3, "c":3, "d":2, "e":1, "f":4, "g":2, "h":4, "i":1, "j":8, "k":5, "l":1, "m":3, "n":1, "o":1, "p":3, "q":10, "r":1, "s":1, "t":1, "u":1, "v":4, "w":4, "x":8, "y":4, "z":10, "wild":0]
    
    static let DEFUALT_LETTER_TYPES: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "wild"]
    
    static let DEFAULT_LETTER_BAG: [String] = ["a", "a", "a", "a", "a", "a", "a", "a", "a", "b", "b", "c", "c", "d", "d", "d", "d", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "f", "f", "g", "g", "g", "h", "h", "i", "i", "i", "i", "i", "i", "i", "i", "i", "j", "k", "l", "l", "l", "l", "m", "m", "n", "n", "n", "n", "n", "n", "o", "o", "o", "o", "o", "o", "o", "o", "p", "p", "q", "r", "r", "r", "r", "r", "r", "s", "s", "s", "s", "t", "t", "t", "t", "t", "t", "u", "u", "u", "u", "v", "v", "w", "w", "x", "y", "y", "z", "wild", "wild"]
    
    static func defaultNumberToLetter(number: Int) -> String {
        guard number >= 0 && number <= 25 else { return "wild" }
        return GameInfo.DEFUALT_LETTER_TYPES[number]
    }
    
    static func defaultLetterToPointValue(letter: String) -> Int {
        guard let value = GameInfo.DEFAULT_LETTER_VALUES[letter] else { return 0 }
        return value
    }
}

//
//  CharacterUtil.swift
//  daag
//
//  Created by Myungkyo Jung on 9/10/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import Foundation

class CharacterUtil {
    enum CharacterType {
        case Eulul, Iga
    }
    
    static func appendPostfix(sourceString: String, type: CharacterType) -> String {
        var resultString = sourceString
        let character = NSString(string: sourceString).characterAtIndex(count(sourceString) - 1)
        if (0xAC00 <= character && character <= 0xD7A3 ){
            if type == .Eulul {
                if haveJongsung(character) {
                    resultString += "을"
                } else {
                    resultString += "를"
                }
            } else if type == .Iga {
                if haveJongsung(character) {
                    resultString += "이"
                } else {
                    resultString += "가"
                }
            }
        }

        return resultString
    }
    
    static func haveJongsung(sourceCharacter: unichar) -> Bool {
        
        var jongsung = (sourceCharacter - 0xAC00)%28
        jongsung = jongsung + 0x11A8
        jongsung--
        
        return (4520 < jongsung && jongsung <= 4547)
    }
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}
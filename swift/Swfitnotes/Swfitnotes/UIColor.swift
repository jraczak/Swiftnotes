//
//  UIColor.swift
//  Swfitnotes
//
//  Created by John Lago on 1/20/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func hexStr (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
        var hexStr = hexStr
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string", terminator: "")
            return UIColor.white;
        }
    }
    
    class var redNoteColor: UIColor {
        get {
            return UIColor.hexStr("#FF5252", alpha: 1.0)
        }
    }
    
    class var lightBlueNoteColor: UIColor {
        get {
            return UIColor.hexStr("#03A9F4", alpha: 1.0)
        }
    }
    
    class var pinkNoteColor: UIColor {
        get {
            return UIColor.hexStr("#FF80AB", alpha: 1.0)
        }
    }
    
    class var yellowNoteColor: UIColor {
        get {
            return UIColor.hexStr("#FFC107", alpha: 1.0)
        }
    }
    
    class var orangeNoteColor: UIColor{
        get {
            return UIColor.hexStr("#FF9800", alpha: 1.0)
        }
    }
    
    class var tealNoteColor: UIColor {
        get {
            return UIColor.hexStr("#64FFDA", alpha: 1.0)
        }
    }
    
    static let colorNoteOptions = [UIColor.redNoteColor, UIColor.tealNoteColor, UIColor.lightBlueNoteColor, UIColor.orangeNoteColor, UIColor.pinkNoteColor, UIColor.yellowNoteColor]
}

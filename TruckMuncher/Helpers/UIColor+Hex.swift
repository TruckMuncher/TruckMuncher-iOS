//
//  UIColor+Hex.swift
//  TruckMuncher
//
//  Created by R0CKSTAR on 6/13/14.
//
//  Modified by Andrew Moore on 10/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if countElements(hex) == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if countElements(hex) == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9")
                }
            } else {
                println("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
            red = 233.0/255.0; green = 30.0/255.0; blue = 99.0/255.0; alpha = 1
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func suggestedTextColor() -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let threshold: CGFloat = 105.0
        var bgDelta = ((red*255.0*0.299) + (green*255.0*0.587) + (blue*255.0*0.114))
        return (255.0-bgDelta < threshold) ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    func transformToColor(destinationColor: UIColor, withPercentage percentage: CGFloat) -> UIColor {
        var baseRed: CGFloat = 0, baseGreen: CGFloat = 0, baseBlue: CGFloat = 0, baseAlpha: CGFloat = 0
        getRed(&baseRed, green: &baseGreen, blue: &baseBlue, alpha: &baseAlpha)
        
        var destinationRed: CGFloat = 0, destinationGreen: CGFloat = 0, destinationBlue: CGFloat = 0, destinationAlpha: CGFloat = 0
        destinationColor.getRed(&destinationRed, green: &destinationGreen, blue: &destinationBlue, alpha: &destinationAlpha)
        
        let red = baseRed + (destinationRed - baseRed)*percentage
        let blue = baseBlue + (destinationBlue - baseBlue)*percentage
        let green = baseGreen + (destinationGreen - baseGreen)*percentage
        let alpha = baseAlpha + (destinationAlpha - baseAlpha)*percentage
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
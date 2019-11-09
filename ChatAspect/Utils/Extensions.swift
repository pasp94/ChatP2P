//
//  Extentions.swift
//  ChatAspect
//
//  Created by Pasquale Spisto on 09/11/2019.
//  Copyright © 2019 pasp_development. All rights reserved.
//

import UIKit

extension UINavigationController {
   override open var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

///Mark: New initializer for Hexadecimal color code
extension UIColor {
   convenience init(hex: String, alpha: CGFloat = 1.0) {
      var rgbValue: UInt64 = 0
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
      
      if (cString.hasPrefix("#")) {
         cString.remove(at: cString.startIndex)
      }
      
      if ((cString.count) != 6) {
         rgbValue = 0
      }
      
      Scanner(string: cString).scanHexInt64(&rgbValue)
      
      
      self.init(
         red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
         green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
         blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
         alpha: alpha
      )
   }
}

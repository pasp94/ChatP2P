//
//  Logger.swift
//  ChatAspect
//
//  Created by Pasquale Spisto on 03/11/2019.
//  Copyright © 2019 pasp_development. All rights reserved.
//

import UIKit

class Logger {
   static func logs(_ object: Any? = nil, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
      #if DEBUG
      let className = (fileName as NSString).lastPathComponent
      
      if let object = object {
         print("• \(object)   - \(functionName) - \(className) #\(lineNumber)")
      } else {
         print("---> \(functionName) - \(className) #\(lineNumber)")
      }
      #endif
   }
   
   static func logError(_ object: Any? = nil, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
      #if DEBUG
      let className = (fileName as NSString).lastPathComponent
      //   print("\(NSDate()): <\(className)> \(functionName) [#\(lineNumber)]| \(object)\n")
      if let object = object {
         print("\n•••••••• \(object)   - \(functionName) - \(className) #\(lineNumber)\n")
      } else {
         print("\n•••••••• \(functionName) - \(className) #\(lineNumber)\n")
      }
      #endif
   }
}

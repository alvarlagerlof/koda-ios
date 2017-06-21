//
//  ExtensionBase64.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 6/20/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation


extension String {
    
    var base64encode: String {
        if self == "" || self.isEmpty || self.characters.count == 0 {
            return ""
            
        } else {
            return String(Data(self.utf8).base64EncodedString())
        }
    
    }
    
    
    var base64decode: String {
        
        if self == "" || self.isEmpty || self.characters.count == 0 {
            return ""
            
        } else {
            let text: String = self.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            let decodedData = Data(base64Encoded: text, options: NSData.Base64DecodingOptions(rawValue: 0))
            
            return NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)! as String
        }
        
    }
    
    
    
}

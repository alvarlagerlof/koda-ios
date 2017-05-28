//
//  Base64Helper.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 2/13/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation

class Base64Helper {
    
    
    class func encode(decoded: String) -> String {
    
        if decoded == "" || decoded.isEmpty || decoded.characters.count == 0 {
            return ""
            
        } else {
            return String(Data(decoded.utf8).base64EncodedString())
            
        }
        
    }
    
    
    
    
    class func decode(encoded: String) -> String {
        
        
        
        if encoded == "" || encoded.isEmpty || encoded.characters.count == 0 {
            return ""
            
        } else {
            
            let text: String = encoded.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            let decodedData = Data(base64Encoded: text, options: NSData.Base64DecodingOptions(rawValue: 0))
            
           
            return NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)! as String
            
        }
        
    }
    
    
    
    
}

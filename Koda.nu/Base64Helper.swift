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
    
        if (decoded == "" || decoded.isEmpty) {
            return "Error"
            
        } else {
            return String(Data(decoded.utf8).base64EncodedString())
            
        }
        
    }
    
    
    
    
    class func decode(encoded: String) -> String {
        
        if (encoded == "" || encoded.isEmpty) {
            return "Error"
            
        } else {
            let decodedData = Data(base64Encoded: encoded, options: NSData.Base64DecodingOptions(rawValue: 0))
            
            return NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue) as! String
            
        }
        
    }
    
    
    
    
}

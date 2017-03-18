//
//  ArchiveItem.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 20/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import Foundation

struct ArchiveItem {
    
    var type: String
    
    var publicID: String
    
    var title: String
    var author: String
    var updated: String
    var description: String
    
    var like_count: String
    var comment_count: String
    var char_count: String
    
    var liked: Bool
    var isAuthor: Bool
    
}
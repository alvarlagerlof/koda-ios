//
//  CommentHeaderViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 10/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class CommentHeaderViewCell: UITableViewCell {
   
    @IBOutlet weak var textView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.numberOfLines = 0
        textView.sizeToFit()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

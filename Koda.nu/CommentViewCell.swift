//
//  CommentViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 10/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        commentLabel.numberOfLines = 0
        commentLabel.sizeToFit()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

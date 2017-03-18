//
//  CommentOfflineViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 15/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit


class CommentsOfflineViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.sizeToFit()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

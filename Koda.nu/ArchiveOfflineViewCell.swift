//
//  ArchiveOfflineCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 11/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class ArchiveOfflineViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//
//  ApiViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 20/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class ApiViewCell: UITableViewCell {
    
    @IBOutlet weak var commandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commandLabel.numberOfLines = 0;
        commandLabel.sizeToFit()
        
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.sizeToFit()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  GuidesTextCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 18/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class GuidesTextCell: UITableViewCell {
    
    @IBOutlet weak var textLabelView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabelView!.numberOfLines = 0
        textLabelView!.sizeToFit()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
    
}

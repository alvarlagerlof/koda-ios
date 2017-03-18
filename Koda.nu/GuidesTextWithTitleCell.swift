//
//  GuidesTextWithHeader.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 18/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class GuidesTextWithTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabelView: UILabel!
    @IBOutlet weak var textLabelView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabelView.numberOfLines = 0
        titleLabelView.sizeToFit()
        
        textLabelView.numberOfLines = 0
        textLabelView.sizeToFit()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
    
}

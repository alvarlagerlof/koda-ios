//
//  MyProjectsNoProejctsViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 16/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit

class ProjectsNoProjectsViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
    }
    
    
    @IBAction func createNew(_ sender: UIButton) {
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

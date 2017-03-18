//
//  MyCreationsViewCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 20/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class ProjectsViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

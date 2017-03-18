//
//  YoutubeCell.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 09/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class YoutubeCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        
    }
    
}
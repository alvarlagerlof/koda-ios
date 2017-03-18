//
//  ArchiveViewCell.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 19/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class ArchiveViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var expandButton: UIButton!

    @IBOutlet weak var moreButton: UIButton!
    
    
    
    // Likes and comments
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var commentView: UIView!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentImage: UIImageView!
    
    
    
    // Constraits
    @IBOutlet weak var moreViewHeight: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moreViewHeight.constant = 0
        moreView.layoutIfNeeded()
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

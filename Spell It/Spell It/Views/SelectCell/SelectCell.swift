//
//  SelectCell.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import UIKit

class SelectCell: UICollectionViewCell {

    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 10
        
    }
    
    override func draw(_ rect: CGRect) {
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: 10).cgPath
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 1
    }

}

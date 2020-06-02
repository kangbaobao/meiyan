//
//  FilterProcessFirstBottomcollCell.swift
//  meiyan
//
//  Created by 康子文 on 2019/11/1.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class FilterProcessFirstBottomcollCell: UICollectionViewCell {

    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        lab.textColor = MYSeetings.BlockColor
        lab.adjustsFontSizeToFitWidth = true
        
    }

}

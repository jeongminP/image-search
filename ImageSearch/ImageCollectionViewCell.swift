//
//  ImageCollectionViewCell.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/02.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil
        super.prepareForReuse()
    }

}

//
//  ImageCollectionViewCell.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/02.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var thumbnailImageView: UIImageView?
    @IBOutlet weak private var titleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        thumbnailImageView?.image = nil
        super.prepareForReuse()
    }
    
    func setThumbnailImageView(image: UIImage) {
        thumbnailImageView?.image = image
    }
    
    func setTitleLabel(title: String) {
        titleLabel?.text = title
    }
}

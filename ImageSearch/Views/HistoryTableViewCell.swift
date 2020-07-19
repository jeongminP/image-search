//
//  HistoryTableViewCell.swift
//  ImageSearch
//
//  Created by USER on 2020/07/13.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    let deleteButtonImageName = "SF_xmark_square_fill"
    let buttonsImageWidth = CGFloat(20)
    let buttonsImageHeight = CGFloat(20)
    let buttonsTintColor = UIColor.gray
    
    @IBOutlet weak private var keywordLabel: UILabel?
    @IBOutlet weak private var searchDateLabel: UILabel?
    @IBOutlet weak private var deleteButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDeleteButtonImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDeleteButtonImage() {
        let deleteButtonImage = UIImage(named: deleteButtonImageName)
        setButtonImage(with: deleteButtonImage, of: deleteButton)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        
    }
    
    func setKeywordLabel(text: String) {
        keywordLabel?.text = text
    }
    
    func setSearchDateLabel(text: String) {
        searchDateLabel?.text = text
    }
    
    private func setButtonImage(with image: UIImage?, of button: UIButton?) {
        guard let image = image, let button = button else { return }
        
        let templateImage = resizedImage(at: image,
                                         for: CGSize(width: buttonsImageWidth,
                                                     height: buttonsImageHeight))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(templateImage, for: .normal)
        button.tintColor = buttonsTintColor
    }
    
    private func resizedImage(at image: UIImage, for size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

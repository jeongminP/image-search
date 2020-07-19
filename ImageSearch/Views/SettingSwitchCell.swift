//
//  SettingSwitchCell.swift
//  ImageSearch
//
//  Created by USER on 2020/07/18.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit

protocol SettingSwitchCellDelegate: class {
    func settingSwitchCell(_ cell: SettingSwitchCell, didTapped exposingSwitch: UISwitch)
}

class SettingSwitchCell: UITableViewCell, View {
    var viewModel: SettingSwitchCellViewModel = SettingSwitchCellViewModel()
    var observer: Observer?
    
    weak var delegate: SettingSwitchCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exposingSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        bindViewModel()
    }
    
    func bindViewModel() {
        observer = Observer()
        observer?.observe(viewModel, target: \.isChanged) { [weak self] viewModel, change in
            self?.titleLabel.text = viewModel.sectionName
            self?.exposingSwitch.isOn = viewModel.isExposing ?? true
        }
    }
    
    func injectDataToViewModel(_ data: SectionExposeInfo) {
        viewModel.model = data
    }
    
    @IBAction private func didTappedExposingSwitch(_ sender: UISwitch) {
        delegate?.settingSwitchCell(self, didTapped: sender)
    }
}

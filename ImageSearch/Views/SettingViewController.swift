//
//  SettingViewController.swift
//  ImageSearch
//
//  Created by USER on 2020/07/17.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit
import SnapKit

final class SettingViewController: UIViewController, View {
    var viewModel: SettingViewModel = SettingViewModel()
    var observer: Observer?
    
    private let buttonStackView = UIStackView()
    private let cancelButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    private let applyButton = UIButton(type: .custom)
    private let tableView = UITableView()
    
    private let switchCellID = "SettingSwitchCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        bindViewModel()
        setupButtons()
        setupTableView()
    }
    
    func bindViewModel() {
        
    }
    
    private func setupButtons() {
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(UIColor.darkGray, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        buttonStackView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        applyButton.setTitle("확인", for: .normal)
        applyButton.setTitleColor(UIColor.systemBlue, for: .normal)
        applyButton.addTarget(self, action: #selector(apply), for: .touchUpInside)
        
        buttonStackView.addSubview(applyButton)
        applyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        buttonStackView.axis = .horizontal
        
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        let cell = UINib(nibName: switchCellID, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: switchCellID)
    }
    
    @objc
    private func cancelButtonClicked(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func apply() {
        viewModel.applySetting()
        dismiss(animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: switchCellID, for: indexPath)
        guard let switchCell = cell as? SettingSwitchCell else {
            return cell
        }
        
        switchCell.delegate = self
        if let data = viewModel.dataForRow(at: indexPath) {
            switchCell.injectDataToViewModel(data)
        }
        return cell
    }
}

extension SettingViewController: SettingSwitchCellDelegate {
    func settingSwitchCell(_ cell: SettingSwitchCell, didTapped exposingSwitch: UISwitch) {
        if let type = cell.viewModel.sectionType {
            viewModel.didTappedSwitch(of: type, with: exposingSwitch.isOn)
        }
    }
}

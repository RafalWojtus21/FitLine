//
//  NotificationViewController.swift
//  Fitmania
//
//  Created by Rafał Wojtuś on 03/01/2024.
//

import UIKit

class NotificationViewController: UIViewController {
    
    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = .now
        return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
    }
    
    private func layoutView() {
        view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.center.equalToSuperview()
        }
    }
}

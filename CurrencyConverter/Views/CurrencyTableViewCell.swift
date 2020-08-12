//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var currencyBackgroundView: UIView!
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyTextField: UITextField!
    
    // MARK: - Свойства
    weak var doneButton: UIToolbar!
    
    // MARK: - Методы
    func setupCell(for currency: (name: String, value: Double)) {
        currencyNameLabel.text = currency.name
        setupTextField(for: currency)
        setupImageView(for: currency)
    }
    
    func setupImageView(for currency: (name: String, value: Double)) {
        if let image = UIImage(named: currency.name) {
            currencyImageView.image = image
        } else {
            currencyImageView.image = UIImage(named: "UnknownCurrency")
        }
    }
    
    func setupTextField(for currency: (name: String, value: Double)) {
        currencyTextField.text = "\(currency.value)"
        currencyTextField.backgroundColor = .systemBackground
        currencyTextField.font = .systemFont(ofSize: 16)
        currencyTextField.textAlignment = .right
        currencyTextField.keyboardType = .decimalPad
        currencyTextField.placeholder = "0"
        currencyTextField.setBottomBorder()
        currencyTextField.createDoneButton()
    }
    
}

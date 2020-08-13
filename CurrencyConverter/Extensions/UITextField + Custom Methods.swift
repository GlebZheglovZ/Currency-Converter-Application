//
//  UITextfield + Custom.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func createDoneButton() {
        let toolBar = UIToolbar()
               toolBar.sizeToFit()
               let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: nil,
                                                action: nil)
               
               let doneButton = UIBarButtonItem(title: "Готово",
                                                style: .done,
                                                target: self,
                                                action: #selector(self.resignFirstResponder))
               doneButton.tintColor = .black
               toolBar.setItems([flexButton, doneButton],
                                animated: false)
        self.inputAccessoryView = toolBar
    }
    
    func convertTextFieldTextIntoDouble() -> Double? {
        guard let value = self.text else { return nil }
        guard let convertedValue = Double(value) else { return nil }
        return convertedValue
    }

}

//
//  CurrencyRatesViewController.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import UIKit

class CurrencyRatesViewController: UIViewController {
    
    // MARK: - Свойства
    private let tableView = UITableView()
    private let reconnectButton = UIButton()
    private let customNavigationBarTitleLabel = UILabel()
    private var safeArea: UILayoutGuide!
    private let networkManager = NetworkManager()
    private var timer: Timer!
    private var date: Date!
    private var dateFormatter: DateFormatter!
    private var defaultCurrencyRateValue = 1.0
    private var selectedCurrency = "EUR"
    private var selectedIndexPath = IndexPath(row: 0, section: 0)
    private var receivedCurrenciesRates = [Currency]()
    
    // MARK: - Методы UIViewController
    override func loadView() {
        super.loadView()
        setupMainView()
        setupTableView()
        setupReconnectButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupKeyboardObservers()
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(fetchDataFromAPI),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    // MARK: - Работа с UI
    private func setupMainView() {
        view.backgroundColor = .systemBackground
        safeArea = view.layoutMarginsGuide
    }
    
    private func setupNavigationBar() {
        customNavigationBarTitleLabel.frame = CGRect(x: 0, y: 0, width: 400, height: 50)
        customNavigationBarTitleLabel.backgroundColor = .systemBackground
        customNavigationBarTitleLabel.numberOfLines = 2
        customNavigationBarTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        customNavigationBarTitleLabel.textAlignment = .center
        customNavigationBarTitleLabel.textColor = .systemGray
        customNavigationBarTitleLabel.text = "Currency Converter\n"
        self.navigationItem.titleView = customNavigationBarTitleLabel
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "CurrencyTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "CurrencyTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    func setupReconnectButton() {
        view.addSubview(reconnectButton)
        reconnectButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        reconnectButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        reconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        reconnectButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        reconnectButton.titleLabel?.numberOfLines = 0
        reconnectButton.setTitle("Нажмите на экран чтобы запросить курс валют с сервера", for: .normal)
        reconnectButton.addTarget(self, action: #selector(reconnectToServer), for: .touchUpInside)
        reconnectButton.isHidden = true
    }
    
    func hideUI(_ isHidden: Bool) {
        DispatchQueue.main.async {
            self.tableView.isHidden = isHidden
            self.reconnectButton.isHidden = !isHidden
        }
    }
    
    private func showAlertController(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                self.hideUI(true)
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
    }
    
    private func reloadDataForTableView() {
        DispatchQueue.main.async { [weak self] in
            // 1. Инициализируем пустой массив который будет хранить в себе IndexPath'ы отображаемых ячеек
            var indexPathsForVisibleRows = [IndexPath]()
            
            // 2. Пытаемся развернуть значение из self.tableView.indexPathaForVisibleRows
            if let unwrappedIndexPathsForVisibleRows = self?.tableView.indexPathsForVisibleRows {
                // 3. Присваиваем извлеченные значения в массив indexPathForVisibleRows
                indexPathsForVisibleRows = unwrappedIndexPathsForVisibleRows
            }
            
            // 4. Если indexPathForVisibleRows пустое то просто делаем reloadData для всей таблицы
            if indexPathsForVisibleRows.isEmpty {
                self?.tableView.reloadData()
                // 5. В противном случае проходимся по элементам массива indexPathsForVisibleRows
            } else {
                // 6. Используем enumerated() чтобы можно было потом выцепить нужный элемент по индексу
                for (index, indexPath) in indexPathsForVisibleRows.enumerated() {
                    // 7. Кастим ячейку до типа CurrencyTableViewCell
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? CurrencyTableViewCell {
                        /* 8. Если аббревиатура валюты в ячейке совпадает с текущей валютой,
                        то удаляем по индексу найденный элемент */
                        if cell.currencyNameLabel.text == self?.selectedCurrency {
                            indexPathsForVisibleRows.remove(at: index)
                        }
                    }
                }
                
                // 9. Перезагружаем отдельные ячейки, которые будут производить расчет на основе введенных нами данных
                self?.tableView.reloadRows(at: indexPathsForVisibleRows, with: .none)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        defaultCurrencyRateValue = convertTextField(textField: textField) ?? defaultCurrencyRateValue
        fetchDataFromAPI()
    }
    
    @objc func textFieldDidTapped(_ textField: UITextField) {
        defaultCurrencyRateValue = convertTextField(textField: textField) ?? defaultCurrencyRateValue
        let textfieldPostion = textField.convert(textField.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: textfieldPostion) {
            selectedCurrency = receivedCurrenciesRates[indexPath.row].key
            selectedIndexPath = indexPath
        }
    }
    
    private func setupTargetsForTextFields(for textfield: UITextField, at indexPath: IndexPath) {
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        textfield.addTarget(self, action: #selector(textFieldDidTapped(_:)), for: UIControl.Event.editingDidBegin)
    }
    
   @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Сортировка/Конвертирование
    private func convertTextField(textField: UITextField) -> Double? {
        guard let value = textField.text else { return 0 }
        guard let convertedValue = Double(value) else { return 0 }
        return convertedValue
    }
    
    private func sortCurrencies(_ currencies: Currencies) -> [Currency] {
        var currencies = Array(currencies.rates)
        currencies.append((selectedCurrency, defaultCurrencyRateValue))
        currencies = currencies.sorted { (element1, element2) -> Bool in
            element1.key < element2.key
        }
        return currencies
    }
    
    private func showRequestTimeOnNavigationBar() {
        date = Date()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        let convertedDate = dateFormatter.string(from: date)
        let attributedString = NSMutableAttributedString()
        let titleText = NSAttributedString(string: "Currency Converter\n")
        let lastUpdatedText = NSAttributedString(string: "Last Update: ",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        let dateText = NSAttributedString(string: convertedDate, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        attributedString.append(titleText)
        attributedString.append(lastUpdatedText)
        attributedString.append(dateText)
        
        DispatchQueue.main.async {
            let customNavigationBarTitle = self.navigationItem.titleView as! UILabel
            customNavigationBarTitle.attributedText = attributedString
        }
    }
    
    // MARK: - Работа с сетью
    @objc func fetchDataFromAPI() {
        networkManager.getCurrenciesRates(for: selectedCurrency) { [weak self] (currencies, response, error) in
            self?.showRequestTimeOnNavigationBar()
           
            self?.networkManager.validate(response: response, error: error) { (title, message) in
                self?.showAlertController(withTitle: title, message: message)
                self?.timer.invalidate()
                self?.timer = nil
            }
            
            if let currencies = currencies, let arrayOfCurrencies = self?.sortCurrencies(currencies) {
                self?.receivedCurrenciesRates = arrayOfCurrencies
                self?.reloadDataForTableView()
            }
            
        }
    }
    
    @objc func reconnectToServer() {
        fetchDataFromAPI()
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(fetchDataFromAPI),
                                     userInfo: nil,
                                     repeats: true)
        hideUI(false)
    }
    
}

// MARK: - Расширение (UITableViewDelegate / UITableViewDataSource)
extension CurrencyRatesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedCurrenciesRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell") as! CurrencyTableViewCell
        let currency = receivedCurrenciesRates[indexPath.row]
        cell.setupCell(for: (currency.key, currency.value))
        cell.currencyTextField.delegate = self
        setupTargetsForTextFields(for: cell.currencyTextField, at: indexPath)
        
        if indexPath != selectedIndexPath {
            cell.currencyTextField.text = String(format: "%.3f", defaultCurrencyRateValue * currency.value)
        }
        
        return cell
    }
    
}

// MARK: - Расширение (UITextFieldDelegate)
extension CurrencyRatesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 10 && string.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) == nil
    }
    
}

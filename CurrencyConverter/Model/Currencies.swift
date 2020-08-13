//
//  Currencies.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import Foundation

struct Currencies: Decodable {
    let base, date: String?
    let rates: [String: Double]?
    
    func sortCurrenciesRates(withSelectedCurrency selectedCurrency: String, currencyRateValue: Double) -> [Currency] {
        var sortedCurrencies = [Currency]()
        if let rates = self.rates {
            sortedCurrencies = Array(rates)
            sortedCurrencies.append((selectedCurrency, currencyRateValue))
            sortedCurrencies = sortedCurrencies.sorted { (element1, element2) -> Bool in
                element1.key < element2.key
            }
        }
        return sortedCurrencies
    }
    
}

typealias Currency = (key: String, value: Double)


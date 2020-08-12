//
//  Currencies.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import Foundation

struct Currencies: Decodable {
    let base, date: String
    let rates: [String: Double]
}

typealias Currency = (key: String, value: Double)


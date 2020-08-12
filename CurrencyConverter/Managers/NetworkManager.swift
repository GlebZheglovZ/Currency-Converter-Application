//
//  NetworkManager.swift
//  CurrencyConverter
//
//  Created by Глеб Николаев on 11.08.2020.
//  Copyright © 2020 Глеб Николаев. All rights reserved.
//

import Foundation

final class NetworkManager {
    
    // MARK: - Свойства
    private let baseURL = "https://revolut.duckdns.org/latest"
    private let sessionConfiguration = URLSessionConfiguration.default
    private let session: URLSession
    private let queue: DispatchQueue
    
    // MARK: - Инициализаторы
    init() {
        sessionConfiguration.timeoutIntervalForResource = 10
        sessionConfiguration.waitsForConnectivity = false
        session = URLSession(configuration: sessionConfiguration)
        queue = DispatchQueue.global(qos: .background)
    }
    
    // MARK: - Методы
    func getCurrenciesRates(for currency: String, completionHandler: @escaping (Currencies?, HTTPURLResponse?, Error?) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "base", value: currency)]
        guard let queryURL = components?.url else { return }
        
        let task = session.dataTask(with: queryURL) { (data, response, error) in
            if let error = error {
                print("Error founded: \(error.localizedDescription)")
            } else if let receivedResponse = response as? HTTPURLResponse,
                (200..<300) ~= receivedResponse.statusCode,
                let receivedData = data {
                if let json = try? JSONDecoder().decode(Currencies.self, from: receivedData) {
                    print("\nReceived data: \(receivedData)")
                    print("Response status code: \(receivedResponse.statusCode)")
                    print("Received JSON successfully decoded into \(Currencies.self) type\n")
                    completionHandler(json, nil, nil)
                } else {
                    print("Can't decode data for type: \(Currencies.self)")
                }
            }
        }
        
        queue.async {
            task.resume()
        }
    }
    
    func validate(response: HTTPURLResponse?, error: Error?, completionHandler: (@escaping (String, String) -> Void)) {
        if let response = response {
            if (400...499) ~= response.statusCode {
                completionHandler("Ошибка", "Произошла ошибка на стороне клиента\nПожалуйста повторите попытку позднее")
            } else if (500...599) ~= response.statusCode {
                completionHandler("Ошибка", "Произошла ошибка на стороне сервера\nПожалуйста, повторите попытку позднее")
            }
        } else if let error = error {
            completionHandler("Ошибка", error.localizedDescription)
        }
    }
    
}

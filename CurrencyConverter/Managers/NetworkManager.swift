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
    private let session: URLSession
    private let sessionConfiguration = URLSessionConfiguration.default
    private var tasksInProgress = [URLSessionDataTask]()
    
    // MARK: - Инициализаторы
    init() {
        sessionConfiguration.timeoutIntervalForResource = 3
        sessionConfiguration.waitsForConnectivity = false
        session = URLSession(configuration: sessionConfiguration)
    }
    
    // MARK: - Методы
    private func cancelAllTasksInProgress() {
        tasksInProgress.forEach { $0.cancel() }
    }
    
    func getCurrenciesRates(for currency: String, completionHandler: @escaping (Currencies?, HTTPURLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: baseURL) else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "base", value: currency)]
        guard let queryURL = components?.url else { return }
        
        let task = session.dataTask(with: queryURL) { [weak self] (data, response, error) in
            if let error = error {
                self?.cancelAllTasksInProgress()
                self?.tasksInProgress.removeAll()
                completionHandler(nil, nil, error)
            } else if let receivedResponse = response as? HTTPURLResponse,
                (200..<300) ~= receivedResponse.statusCode,
                let receivedData = data {
                if let json = try? JSONDecoder().decode(Currencies.self, from: receivedData) {
                    self?.tasksInProgress.removeAll()
                    completionHandler(json, nil, nil)
                } else {
                    print("Can't decode data for type: \(Currencies.self)")
                    self?.cancelAllTasksInProgress()
                }
            }
        }
        
        tasksInProgress.append(task)
        task.resume()
        
    }
    
    func validate(response: HTTPURLResponse?, error: Error?, completionHandler: (@escaping (String, String) -> Void)) {
        if let response = response {
            if (400...499) ~= response.statusCode {
                completionHandler("Network Error", "Receiver client error: \(response.statusCode) \nPlease try again later")
            } else if (500...599) ~= response.statusCode {
                completionHandler("Network Error", "Received server error: \(response.statusCode) \nPlease try again later")
            }
        } else if let error = error {
            completionHandler("Network Error", error.localizedDescription)
        }
    }
    
}

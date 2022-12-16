//
//  APICaller.swift
//  testAPI
//
//  Created by Артем Макар on 17.11.22.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    static var requestURL = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(APICaller.RequestCryptoParameters.currency)&\(APICaller.RequestCryptoParameters.category)&per_page=\(APICaller.RequestCryptoParameters.valuePerPage)&page=\(APICaller.RequestCryptoParameters.page)&sparkline=false&price_change_percentage=1h"
    struct RequestCryptoParameters {
        static var ids = ""
        static var currencySymbol = "$"
        static var currency = "usd"
        static let valuePerPage = "20"
        static var category = ""
        static var page = 1

    }
    
    struct RequestCryptoHistory {
        static var period = "max"
    }
    
    private init(){
        
    }
    
    public func getAllCryptoData(complition: @escaping (Result<[CoinListElement], Error>) -> Void){
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(APICaller.RequestCryptoParameters.currency)&\(APICaller.RequestCryptoParameters.category)&per_page=\(APICaller.RequestCryptoParameters.valuePerPage)&page=\(APICaller.RequestCryptoParameters.page)&sparkline=false&price_change_percentage=1h") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let cryptos = try JSONDecoder().decode([CoinListElement].self, from: data)
                complition(.success(cryptos))
            }
            catch {
                complition(.failure(error))
            }
            
        }
        task.resume()
    }

    public func getCryptoHistory(complition: @escaping (Result<CoinHistory, Error>) -> Void){
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(CryptoStruct.cryptoCell!.id)/market_chart?vs_currency=\(APICaller.RequestCryptoParameters.currency)&days=\(APICaller.RequestCryptoHistory.period)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let cryptos = try JSONDecoder().decode(CoinHistory.self, from: data)
                complition(.success(cryptos))
            }
            catch {
                complition(.failure(error))
            }
            
        }
        task.resume()
    }
    
    public func getAllFavoriteCrypto(complition: @escaping (Result<[CoinListElement], Error>) -> Void){
        APICaller.RequestCryptoParameters.ids = ""
        guard let array = CoreDataManager.user.relationship else { return }
        for i in array {
            APICaller.RequestCryptoParameters.ids += "\(((i as AnyObject).cryptoID!)!)%2C%20"
        }
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(APICaller.RequestCryptoParameters.currency)&ids=\(APICaller.RequestCryptoParameters.ids)&per_page=250&page=1&sparkline=false&price_change_percentage=1h") else {
            print("нашел")
            return
        }
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let cryptos = try JSONDecoder().decode([CoinListElement].self, from: data)
                complition(.success(cryptos))
            }
            catch {
                complition(.failure(error))
            }
            
        }
        task.resume()
    }
    

}

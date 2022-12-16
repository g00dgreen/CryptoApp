//
//  Models.swift
//  testAPI
//
//  Created by Артем Макар on 20.11.22.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//let coinList = try? newJSONDecoder().decode(CoinList.self, from: jsonData)

import Foundation

// MARK: - модель для api в главном меню
struct CoinListElement: Codable {
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let priceChange : Double
    let percentageChange : Double?
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case priceChange = "price_change_24h"
        case percentageChange = "price_change_percentage_1h_in_currency"
    }
}
//typealias CoinList = [CoinListElement]

struct CryptoStruct {
    static var arrayOfCrypto = [CryptoTableViewCellViewModel]()
    static var viewModels = [CryptoTableViewCellViewModel]()
    static var cryptoCell: CryptoTableViewCellViewModel? 
    static var favoriteList = [CryptoTableViewCellViewModel]()
}



// MARK: - модель для api истории цен

struct CoinHistory: Codable {
    let prices: [[Double: Double]]
    let marketCaps: [[Double?]]
    let totalVolumes: [[Double?]]

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}

struct ChartValueStruct {
    static var oneDayTime = [Double]()
    static var oneDayValue = [Double]()
    static var oneMonthTime = [Double]()
    static var oneMonthValue = [Double]()
    static var oneYearTime = [Double]()
    static var oneYearValue = [Double]()
    static var maxTime = [Double]()
    static var maxValue = [Double]()
}



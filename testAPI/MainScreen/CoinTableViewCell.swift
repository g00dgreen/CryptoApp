//
//  CoinTableViewCell.swift
//  testAPI
//
//  Created by Артем Макар on 18.11.22.
//

import UIKit

struct CryptoTableViewCellViewModel {
    let name: String
    let currentPrice: String
    let symbol: String
    let murketCap: String
    let imageURL : String
    let id: String
    let priceChange: Double
    let percentageChange: Double?
    var isFavorite = false
}

class CoinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var name: UILabel!
        
    static let identifire = "CoinTableViewCell"
    
    
    func config(with viewModel: CryptoTableViewCellViewModel) {
        
        name.text = viewModel.name
        price.text = viewModel.currentPrice
        id.text = viewModel.symbol
        if viewModel.priceChange > 0 {
            price.textColor = .systemGreen
        } else {
            price.textColor = .systemRed
        }
        
        if let url = URL(string: viewModel.imageURL) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
              if let data = data {
                DispatchQueue.main.async {
                    self?.coinImage.image = UIImage(data: data)
                }
            }
            
            }
            task.resume()
        }
    }
}

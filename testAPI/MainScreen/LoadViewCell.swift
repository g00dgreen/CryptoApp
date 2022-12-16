//
//  LoadViewCell.swift
//  testAPI
//
//  Created by Артем Макар on 23.11.22.
//

import UIKit

class LoadViewCell: UITableViewCell {
    
    static let identifire = "loadMore"
    weak var loadMoreCryptoDelegate: LoadMoreCryptoDelegate?
  
    @IBAction func loadMoreButton(_ sender: Any) {
        print(CryptoStruct.favoriteList.count)
        APICaller.RequestCryptoParameters.page += 1
        loadMoreCryptoDelegate?.call()
        print(CryptoStruct.favoriteList.count)
        
    }
    

}

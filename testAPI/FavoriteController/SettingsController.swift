//
//  SettingsController.swift
//  testAPI
//
//  Created by Артем Макар on 18.11.22.
//

import UIKit

class SettingsController: UIViewController {
    
    var searchArray : [CryptoTableViewCellViewModel] = []
    var search = UISearchController()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        self.navigationItem.searchController = search
        
        APICaller.shared.getAllFavoriteCrypto { [weak self] result in
            switch result {
            case .success(let models):
               
                CryptoStruct.favoriteList = models.compactMap({ CryptoTableViewCellViewModel.init(name: $0.name, currentPrice: String($0.currentPrice) + "\(APICaller.RequestCryptoParameters.currencySymbol)", symbol: $0.symbol, murketCap: String($0.marketCap) + "\(APICaller.RequestCryptoParameters.currencySymbol)", imageURL: $0.image, id: $0.id, priceChange: $0.priceChange, percentageChange: $0.percentageChange ?? 0)
                })
                DispatchQueue.main.async {
                  
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("error fav")
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
                
        print(InternetConnectionManager.isConnectedToNetwork())
        getFavorite()
        tableView.reloadData()

    }

}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearch() {
            return searchArray.count
        }
        return CryptoStruct.favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        CryptoStruct.cryptoCell = CryptoStruct.favoriteList[indexPath.row]
        performSegue(withIdentifier: "toCoinViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "2")
        var content = cell.defaultContentConfiguration()
        if isSearch() {
            content.text = searchArray[indexPath.row].name
            content.secondaryText = searchArray[indexPath.row].currentPrice
            cell.contentConfiguration = content
            
            return cell
        }
        content.text = CryptoStruct.favoriteList[indexPath.row].name
        content.secondaryText = CryptoStruct.favoriteList[indexPath.row].currentPrice
        cell.contentConfiguration = content
        
        return cell
    }
}

extension SettingsController {
    
    func getFavorite(){
       
        APICaller.shared.getAllFavoriteCrypto { [weak self] result in
            switch result {
            case .success(let models):
                CryptoStruct.favoriteList = models.compactMap({ CryptoTableViewCellViewModel.init(name: $0.name, currentPrice: String($0.currentPrice) + "\(APICaller.RequestCryptoParameters.currencySymbol)", symbol: $0.symbol, murketCap: String($0.marketCap) + "\(APICaller.RequestCryptoParameters.currencySymbol)", imageURL: $0.image, id: $0.id, priceChange: $0.priceChange, percentageChange: $0.percentageChange ?? 0)
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("error fav")
            }
        }
    }
}
    
extension SettingsController: UISearchResultsUpdating {
    
    func isSearch() -> Bool {
        return !(search.searchBar.text?.isEmpty ?? true) && search.isActive
    }
    
    func searchCrypto(text: String) -> [CryptoTableViewCellViewModel]{
        
        searchArray = CryptoStruct.favoriteList
        searchArray = searchArray.filter { crypto in
            return crypto.name.lowercased().contains(text.lowercased())
        }
        return searchArray
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard search.searchBar.text != nil else { return }
        searchCrypto(text: search.searchBar.text!)
        tableView.reloadData()
    }
}



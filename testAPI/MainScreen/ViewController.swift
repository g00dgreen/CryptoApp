//
//  ViewController.swift
//  testAPI
//
//  Created by Артем Макар on 14.11.22.
//

import UIKit

protocol LoadMoreCryptoDelegate: AnyObject {
    func call()
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var coinTableView: UITableView!
    var coreDataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let action4 = UIAction(title: "cryptocurrency"){ _ in
            self.updateCrypto(currency: APICaller.RequestCryptoParameters.currency, category: "category=cryptocurrency")
        }
        let action3 = UIAction(title: "popularity"){ _ in
            self.updateCrypto(currency: APICaller.RequestCryptoParameters.currency, category: "")
        }
        let action2 = UIAction(title: "EUR"){ _ in
            APICaller.RequestCryptoParameters.currencySymbol = "€"
            self.updateCrypto(currency: "eur", category: APICaller.RequestCryptoParameters.category)
        }
        let action1 = UIAction(title: "USD"){ _ in
            APICaller.RequestCryptoParameters.currencySymbol = "$"
            self.updateCrypto(currency: "usd", category: APICaller.RequestCryptoParameters.category)
        }
        let currency = UIMenu(title: "test2", options: .displayInline, children:[
                            action1, action2])
        let category = UIMenu(title: "test", options: .displayInline, children : [
            action3,
            action4])
        
        let menu = UIMenu(children: [currency, category])
        
        let queue = DispatchQueue(label: "InternetConnectionManager", qos: .background)
        queue.async {
            while true {
                sleep(5)
                if !InternetConnectionManager.isConnectedToNetwork() {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "internet connection problems", message: "check your internet connection and try again", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .cancel){ _ in
                            if InternetConnectionManager.isConnectedToNetwork() {
                                self.call()
                            }
                        }
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }

        
        navigationTitle.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "list.bullet"), primaryAction: nil, menu: menu)

        coinTableView.dataSource = self
        coinTableView.delegate = self
        
        navigationTitle.title = "All crypto"
        
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                //print(models.count)
                CryptoStruct.arrayOfCrypto = models.compactMap({ CryptoTableViewCellViewModel.init(name: $0.name, currentPrice: String($0.currentPrice) + "\(APICaller.RequestCryptoParameters.currencySymbol)", symbol: $0.symbol, murketCap: String($0.marketCap) + "\(APICaller.RequestCryptoParameters.currencySymbol)", imageURL: $0.image, id: $0.id, priceChange: $0.priceChange, percentageChange: $0.percentageChange ?? 0)
                    
                })
                CryptoStruct.viewModels.append(contentsOf: CryptoStruct.arrayOfCrypto)
                DispatchQueue.main.async {
                    self?.coinTableView.reloadData()
                }
            case .failure(_):
                print("error ?")
            }
        }
        
    }

    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CryptoStruct.viewModels.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(CryptoStruct.viewModels.count)
        CryptoStruct.cryptoCell = CryptoStruct.viewModels[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = coinTableView.dequeueReusableCell(withIdentifier: LoadViewCell.identifire, for: indexPath) as! LoadViewCell
        cell.loadMoreCryptoDelegate = self
        
        if indexPath.row < CryptoStruct.viewModels.count {
            
            guard let cell = coinTableView.dequeueReusableCell(withIdentifier: CoinTableViewCell.identifire, for: indexPath) as? CoinTableViewCell else {
                fatalError()
            }
            cell.config(with: CryptoStruct.viewModels[indexPath.row])
            return cell
        }
        return cell
    }
    

}

extension ViewController: LoadMoreCryptoDelegate {

    func updateCrypto(currency curnc: String, category catgr: String) {
        CryptoStruct.viewModels.removeAll()
        APICaller.RequestCryptoParameters.page = 1
        APICaller.RequestCryptoParameters.currency = curnc
        APICaller.RequestCryptoParameters.category = catgr
        call()
        
    }

    
    func call(){
        print("https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(APICaller.RequestCryptoParameters.currency)&\(APICaller.RequestCryptoParameters.category)&per_page=\(APICaller.RequestCryptoParameters.valuePerPage)&page=\(APICaller.RequestCryptoParameters.page)&sparkline=false&price_change_percentage=1h")
        print("chzh")
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                CryptoStruct.arrayOfCrypto = models.compactMap({ CryptoTableViewCellViewModel.init(name: $0.name, currentPrice: String($0.currentPrice) + "\(APICaller.RequestCryptoParameters.currencySymbol)", symbol: $0.symbol, murketCap: String($0.marketCap) + "\(APICaller.RequestCryptoParameters.currencySymbol)", imageURL: $0.image, id: $0.id, priceChange: $0.priceChange, percentageChange: $0.percentageChange ?? 0)
                    
                })
                CryptoStruct.viewModels.append(contentsOf: CryptoStruct.arrayOfCrypto)
                DispatchQueue.main.async {
                    self?.coinTableView.reloadData()
                }
            case .failure(_):
                print("error 2")
            }
        }
    }

}

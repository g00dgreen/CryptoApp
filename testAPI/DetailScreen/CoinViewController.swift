//
//  CoinViewController.swift
//  testAPI
//
//  Created by Артем Макар on 18.11.22.
//

import UIKit
import Charts


class CoinViewController: UIViewController {
    
    var yValues: [ChartDataEntry] = []
    var dateValues: [Double] = []
    
    @IBOutlet weak var isFavoriteBattonSettings: UIBarButtonItem!
    @IBOutlet weak var selectedValueLabel: UILabel!
    @IBOutlet weak var capLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var percentageChange1h: UILabel!
    @IBOutlet weak var change24hLabel: UILabel!
    
    
    var segmentControl: UISegmentedControl = {
        var segmentSettings = UISegmentedControl()
        segmentSettings = UISegmentedControl(items: ["24h", "1M", "1Y", "max"])
        segmentSettings.frame = CGRect(x: 52, y: 427, width: 360, height: 30)
        segmentSettings.selectedSegmentIndex = 3
        segmentSettings.isEnabled = false
        return segmentSettings
    }()
    
    let activityIndicator : UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 135, y: 135, width: 30, height: 30)
        return indicator
    }()
    
    lazy var lineChartView: LineChartView = {
        let chartView1 = LineChartView()
        chartView1.backgroundColor = .white
        chartView1.frame = CGRect(x: 52, y: 106, width: 300, height: 300)
        chartView1.rightAxis.enabled = false
        chartView1.pinchZoomEnabled = false
        chartView1.doubleTapToZoomEnabled = false
        
        var yAxis = chartView1.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 10)
        yAxis.setLabelCount(12, force: false)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.labelPosition = .outsideChart
        yAxis.drawGridLinesEnabled = false
        

        chartView1.xAxis.drawGridLinesEnabled = false
        chartView1.xAxis.accessibilityElementsHidden = true
        chartView1.xAxis.valueFormatter = self
        chartView1.xAxis.labelPosition = .bottom
        chartView1.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chartView1.xAxis.labelTextColor = .black
        chartView1.xAxis.axisLineColor = .black
        
        return chartView1
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center.x = view.center.x
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addSubview(lineChartView)
        lineChartView.isHidden = true
        lineChartView.center.x = view.center.x
        lineChartView.delegate = self
        
        view.addSubview(segmentControl)
        segmentControl.addTarget(self, action: #selector(updeteChart), for: .valueChanged)
        segmentControl.center.x = view.center.x
        
        clearCryptoData()
    
        for i in 0..<CryptoStruct.favoriteList.count {
            if CryptoStruct.favoriteList[i].id == CryptoStruct.cryptoCell!.id {
                isFavoriteBattonSettings.image = UIImage(systemName: "star.fill")
                CryptoStruct.cryptoCell?.isFavorite = true
            }
        }
        

        
        self.navigationItem.title = CryptoStruct.cryptoCell!.name
        percentageChange1h.text = "Change 1h: \(symbolChange().1)\(Float(CryptoStruct.cryptoCell!.percentageChange ?? 0))%"
        change24hLabel.text = "Change 24h: \(symbolChange().0)\(Float(CryptoStruct.cryptoCell!.priceChange))\(APICaller.RequestCryptoParameters.currencySymbol)"
        coinLabel.text = "Price: " + "\(CryptoStruct.cryptoCell!.currentPrice)"
        capLabel.text = "Market cap: \(CryptoStruct.cryptoCell!.murketCap)"
        
        
        let queue = DispatchQueue(label: "", qos: .utility)
        let semaphore = DispatchSemaphore(value: 1)
        for i in 0..<4 {
                queue.async {
                    semaphore.wait()
                APICaller.shared.getCryptoHistory { [weak self] result in

                    switch result {
                    case .success(let models):
                            models.prices.map {
                                switch i {
                                    case 0: for (date, value) in $0 {
                                        ChartValueStruct.maxTime.append(date)
                                ChartValueStruct.maxValue.append(value)
                                APICaller.RequestCryptoHistory.period = "1"
                            }
                            case 1: for (date, value) in $0 {
                                ChartValueStruct.oneDayTime.append(date)
                                ChartValueStruct.oneDayValue.append(value)
                                APICaller.RequestCryptoHistory.period = "30"
                            }
                            case 2: for (date, value) in $0 {
                                ChartValueStruct.oneMonthTime.append(date)
                                ChartValueStruct.oneMonthValue.append(value)
                                APICaller.RequestCryptoHistory.period = "365"
                            }
                            case 3: for (date, value) in $0 {
                                ChartValueStruct.oneYearTime.append(date)
                                ChartValueStruct.oneYearValue.append(value)
                                APICaller.RequestCryptoHistory.period = "max"
                            }
                                
                            default : break
                            }
                        }
                        for i in 0..<ChartValueStruct.maxValue.count {
                            self?.yValues.append(ChartDataEntry(x: Double(i + 1), y: ChartValueStruct.maxValue[i]))
                        }
                        for i in 0..<ChartValueStruct.maxTime.count {
                            self?.dateValues.append(ChartValueStruct.maxTime[i])
                        }
                        semaphore.signal()
                        if i == 3 {
                            DispatchQueue.main.async { [self] in
                            self?.activityIndicator.stopAnimating()
                            self!.lineChartView.isHidden = false
                            self!.segmentControl.isEnabled = true
                            self?.setData()
                        }
                        }
                    case .failure(_):
                        print("chart error")
                    }
                }
            }

        }
            }

    @IBAction func isFavoriteButtonAction(_ sender: Any) {
        if InternetConnectionManager.isConnectedToNetwork() {
            CryptoStruct.cryptoCell!.isFavorite = !CryptoStruct.cryptoCell!.isFavorite
            isFavoriteFunc()
        } else {
            print("error connection")
        }
    }
}

extension CoinViewController: ChartViewDelegate, AxisValueFormatter {
    
    func isFavoriteFunc() {
        let isFavorite = CryptoStruct.cryptoCell!.isFavorite
       // let favorite = Favorite(context: CoreDataManager.coreDataManager.viewContext)
        
        if isFavorite == true {
            //CryptoStruct.favoriteList.append(CryptoStruct.cryptoCell!)
            CoreDataManager.coreDataManager.apdateUser(id: CryptoStruct.cryptoCell!.id, isAdd: true)
            //favorite.cryptoID = CryptoStruct.cryptoCell!.id
            //CoreDataManager.user.addToRelationship(favorite)
            //CoreDataManager.coreDataManager.saveContext()
            isFavoriteBattonSettings.image = UIImage(systemName: "star.fill")
        } else {
            for i in 0..<CryptoStruct.favoriteList.count {
                if CryptoStruct.favoriteList[i].id == CryptoStruct.cryptoCell!.id {
                    print(CoreDataManager.user.relationship?.count, "bibok")
                    CoreDataManager.coreDataManager.apdateUser(id: CryptoStruct.favoriteList[i].id, isAdd: false)
                    //CryptoStruct.favoriteList.remove(at: i)
                   
//                    favorite.cryptoID = CryptoStruct.favoriteList[i].id
//                    CoreDataManager.user.removeFromRelationship(favorite)
                    print(CoreDataManager.user.relationship?.count, "bibok")
                    //CoreDataManager.coreDataManager.saveContext()
                    isFavoriteBattonSettings.image = UIImage(systemName: "star")
                    return
                }
            }

        }
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedValueLabel.text = "\(highlight.y)\(APICaller.RequestCryptoParameters.currencySymbol)"
    }
    
    func symbolChange() -> (String, String) {
        var symbolChange = ""
        var percentChangeSymbol = ""
        
        if (CryptoStruct.cryptoCell!.percentageChange ?? 0) > 0 {
            percentChangeSymbol = "+"
        } else if (CryptoStruct.cryptoCell!.priceChange) > 0 {
            symbolChange = "+"
        } else {
            symbolChange = ""
        }
        
        
        return (symbolChange, percentChangeSymbol)
    }
    
    @objc func updeteChart(target: UISegmentedControl){
        
        dateValues.removeAll()
        yValues.removeAll()
        
        if target == self.segmentControl {
            let segmentIndex = target.selectedSegmentIndex
            switch segmentIndex {
                case 0:
                    for i in 0..<ChartValueStruct.oneDayValue.count {
                        self.yValues.append(ChartDataEntry(x: Double(i + 1), y: ChartValueStruct.oneDayValue[i]))
                    }
                    for i in 0..<ChartValueStruct.oneDayTime.count {
                        self.dateValues.append(ChartValueStruct.oneDayTime[i])
                    }
                case 1:
                    for i in 0..<ChartValueStruct.oneMonthValue.count {
                        self.yValues.append(ChartDataEntry(x: Double(i + 1), y: ChartValueStruct.oneMonthValue[i]))
                    }
                    for i in 0..<ChartValueStruct.oneMonthTime.count {
                        self.dateValues.append(ChartValueStruct.oneMonthTime[i])
                    }
                case 2:
                    for i in 0..<ChartValueStruct.oneYearValue.count {
                        self.yValues.append(ChartDataEntry(x: Double(i + 1), y: ChartValueStruct.oneYearValue[i]))
                    }
                    for i in 0..<ChartValueStruct.oneYearTime.count {
                        self.dateValues.append(ChartValueStruct.oneYearTime[i])
                    }
                case 3:
                    for i in 0..<ChartValueStruct.maxValue.count {
                        self.yValues.append(ChartDataEntry(x: Double(i + 1), y: ChartValueStruct.maxValue[i]))
                    }
                    for i in 0..<ChartValueStruct.maxTime.count {
                        self.dateValues.append(ChartValueStruct.maxTime[i])
                    }
                default : break
            }
            setData()
        }
    }
    
    func clearCryptoData(){
        ChartValueStruct.maxTime.removeAll()
        ChartValueStruct.maxValue.removeAll()
        ChartValueStruct.oneDayTime.removeAll()
        ChartValueStruct.oneDayValue.removeAll()
        ChartValueStruct.oneMonthTime.removeAll()
        ChartValueStruct.oneMonthValue.removeAll()
        ChartValueStruct.oneYearTime.removeAll()
        ChartValueStruct.oneYearValue.removeAll()
        dateValues.removeAll()
        yValues.removeAll()
    }
    
    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        var dateString = "test"
        let date = Date(timeIntervalSince1970: ((dateValues[Int(value) - 1]) / 1000) + 10800)
        let dayTimePeriodFormatter = DateFormatter()
        
        switch self.segmentControl.selectedSegmentIndex {
            case 0: dayTimePeriodFormatter.dateFormat = "HH:mm"
            case 1: dayTimePeriodFormatter.dateFormat = "dd.MM"
            case 2: dayTimePeriodFormatter.dateFormat = "dd.MM.yyyy"
            case 3: dayTimePeriodFormatter.dateFormat = "MM.YY"
        default : break
        }
        
        dateString = dayTimePeriodFormatter.string(from: date)
        return dateString
        
    }

    func setData() {
        
        let set1 = LineChartDataSet(entries: yValues)
        
        lineChartView.leftAxis.axisMinimum = yValues.sorted(by: {$0.y < $1.y})[0].y * 0.99
        lineChartView.leftAxis.axisMaximum = yValues.sorted(by: {$0.y > $1.y})[0].y * 1.01
        
        if yValues[0].y > yValues[yValues.count - 1].y {
            set1.setColor(.red)
            set1.fillColor = .red
        } else {
            set1.setColor(.systemGreen)
            set1.fillColor = .systemGreen
        }
        
        set1.label = "\(CryptoStruct.cryptoCell!.name)"
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = true
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 1
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
        
    }

}

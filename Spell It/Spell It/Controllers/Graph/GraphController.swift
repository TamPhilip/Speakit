//
//  GraphController.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-23.
//  Copyright © 2018 Spell It. All rights reserved.
//

import UIKit
import ChameleonFramework
import Charts
import FirebaseFirestore


class GraphController: UIViewController {
    
    public var toSave = 0
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: "BarChartCell", bundle: nil)
            self.collectionView.register(nib, forCellWithReuseIdentifier: "BarChartCell")
            let nibTwo = UINib(nibName: "CombinedChartCell", bundle: nil)
            self.collectionView.register(nibTwo, forCellWithReuseIdentifier: "CombinedChartCell")
            let nibThree = UINib(nibName: "LineGraphCell", bundle: nil)
            self.collectionView.register(nibThree, forCellWithReuseIdentifier: "LineGraphCell")
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.isPagingEnabled = true
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFromDatabase { (success, error) in
            if success {
                
            } else {
                print(error)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(addListener), name: .updateTables, object: nil)
        
        guard let nav = self.navigationController else {return}
        
        nav.navigationBar.layer.masksToBounds = false
        nav.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        nav.navigationBar.layer.shadowOpacity = 0.8
        nav.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        nav.navigationBar.layer.shadowRadius = 2
        
        guard let font = UIFont(name: "Futura", size: 20) else {return}
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor:UIColor.darkGray, NSAttributedString.Key.font: font as Any]
        nav.navigationBar.titleTextAttributes = textAttributes
        
        nav.view.backgroundColor = UIColor(hexString: "F5F5F5")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    
    @objc func addListener() {
        toSave += 1
        self.collectionView.reloadData()
    }
}

extension GraphController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let wordsLearned: [Double] = [10, 12, 15, 5, 2, 10, Double(toSave)]
        
        
        if indexPath.item == 0 {
            let model = collectionView.dequeueReusableCell(withReuseIdentifier: "BarChartCell", for: indexPath)
            guard let cell = model as? BarChartCell else {return model}
            
            let newData = wordsLearned
            
            setBarChart(cell: cell, datapoints: days, values: newData)
            
            return cell
        }
        else if indexPath.item == 1 {
            let model = collectionView.dequeueReusableCell(withReuseIdentifier: "CombinedChartCell", for: indexPath)
            guard let cell = model as? CombinedChartCell else {
                return model
            }
            
            setCombinedChart(cell: cell)
            
            return cell
        }
        else if indexPath.item == 2 {
            
        } else {
            
        }
        
        let model = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath)
        guard let cell = model as? LineGraphCell else {
            return model
        }
        let newData = wordsLearned
        
        return setLineGraph(cell: cell, values: getValuesForLine(values: newData))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? BarChartCell {
            contentLabel.text = "   Daily"
            cell.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
        
        if let cell = cell as? LineGraphCell {
            contentLabel.text = "   Total Weekly"
            cell.lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
        
        if let cell = cell as? CombinedChartCell {
            contentLabel.text = "   Compared to Average"
            cell.combinedChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func getFromDatabase(_ completionHandler: @escaping (Bool, Error?) -> ()) {
        let db = Firestore.firestore().collection("userdata").document("0")
        
        db.getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            guard let data = snapshot.data() else {
                return
            }
            
            data.forEach({ (key, value) in
                success[key] = true
                self.toSave += 1
                
            })
            self.collectionView.reloadData()
        }
    }

}


// MARK: Set Charts

extension GraphController {
    func setBarChart(cell: BarChartCell,datapoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        cell.barChart.noDataText = "There is currently no data, please practice to acquire data!"
        cell.barChart.noDataTextColor = UIColor.black
        cell.barChart.noDataFont = UIFont(name: "Futura", size: 10)
        
        
        let data = shuffleDaysOfWeek(datapoints: datapoints, values: values)
        for i in  0..<datapoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: data.yDatapoint[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Words learned by day")
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.valueFormatter = BarChartValueFormatter()
        print(chartDataSet.values)
        let chartData = BarChartData(dataSet: chartDataSet)
        
        
        let dailyQuotaSetByParent = ChartLimitLine(limit: 5, label: "Daily")
        dailyQuotaSetByParent.valueFont = UIFont(name: "Futura", size: 12)!
        dailyQuotaSetByParent.labelPosition = .leftBottom
        
        cell.barChart.rightAxis.addLimitLine(dailyQuotaSetByParent)
        cell.barChart.data = chartData
        cell.barChart.rightAxis.enabled = true
        cell.barChart.xAxis.valueFormatter = BarChartXAxisFormatter(dayOfWeeks: data.xDatapoint)
        cell.barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        cell.barChart.xAxis.drawGridLinesEnabled = false
        cell.barChart.rightAxis.drawGridLinesEnabled = false
        cell.barChart.pinchZoomEnabled = false
        cell.barChart.dragEnabled = false
        cell.barChart.setScaleEnabled(false)
    }
    
    func shuffleDaysOfWeek(datapoints: [String], values: [Double]) -> (xDatapoint: [Int], yDatapoint: [Double]) {
        var index = datapoints.firstIndex(of: Date().dayOfWeek() ?? "Mon")!
        
        var dayValues: [Double] = []
        var daysOfWeek: [Int] = []
        
        while dayValues.count != datapoints.count {
            if index >= 0 {
                dayValues.append(values[index])
                daysOfWeek.append(index)
                index -= 1
            } else {
                index = 6
            }
        }
        return (daysOfWeek, dayValues.reversed())
    }
}


// MARK: COmbined Chart Cell
extension GraphController {
    func setCombinedChart(cell: CombinedChartCell) {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        print("Here")
        let averageMonth : [Double] = [201, 195, 220, 203, 173, 180, 192, 160, 186, 150, 160, 140 + Double(toSave) / 3]
        let yourMonth : [Double] = [220, 184, 230, 170, 160, 201, 195, 155, 201, 130, 170, 130 + Double(toSave)]
        
        var averageData : [ChartDataEntry] = []
        var yourData: [ChartDataEntry] = []
        print("Here")
        for i in 0...11 {
            let averageEntry = ChartDataEntry(x: Double(i), y: averageMonth[i])
            averageData.append(averageEntry)
            
            
            let yourEntry = BarChartDataEntry(x: Double(i), y: yourMonth[i])
            yourData.append(yourEntry)
        }
        
        var averageSet = LineChartDataSet(values: averageData, label: "The average number of correct words per month (all users)")
        print(averageSet.values)
//        averageSet.
        averageSet.setColor(UIColor.flatForestGreen())
        averageSet.setCircleColor(UIColor.flatForestGreen())
        var yourSet = BarChartDataSet(values: yourData, label: "Total number of correct words per month")
        yourSet.setColor(UIColor.flatSkyBlue())
        print(yourSet.values)
        
        let data = CombinedChartData()
        data.lineData = LineChartData(dataSet: averageSet)
        data.barData = BarChartData(dataSet: yourSet)
        cell.combinedChartView.data = data
        
        cell.combinedChartView.xAxis.enabled = true
        cell.combinedChartView.xAxis.labelPosition = .bottom
        cell.combinedChartView.xAxis.axisMinimum = 0
        cell.combinedChartView.backgroundColor = UIColor.white
        cell.combinedChartView.xAxis.axisRange = 12
        cell.combinedChartView.pinchZoomEnabled = true
        cell.combinedChartView.dragEnabled = true
        cell.combinedChartView.setScaleEnabled(true)
        cell.combinedChartView.xAxis.axisMinimum = -0.5;
        cell.combinedChartView.xAxis.axisMaximum = Double(12) - 0.5;
    }
    
    func shuffleMonths(months: [String], values: [Double]) -> (xDatapoint: [Int], yDatapoint: [Double]) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let nameOfMonth = dateFormatter.string(from: now)
        
        var indexOfCurrentMonth = months.firstIndex(of: nameOfMonth) ?? 0
        
        var monthValues: [Double] = []
        var month: [Int] = []
        
        while monthValues.count != months.count {
            if indexOfCurrentMonth >= 0 {
                monthValues.append(values[indexOfCurrentMonth])
                month.append(indexOfCurrentMonth)
                indexOfCurrentMonth -= 1
            } else {
                indexOfCurrentMonth = 12
            }
        }
        return (month, monthValues.reversed())
    }
}

// MARK: Line Graph
extension GraphController {
    
    func setLineGraph(cell: LineGraphCell, values: [Double]) -> LineGraphCell{
        
        cell.lineChartView.data = nil
        
        let bestWeek : [Double] = [15, 12, 9, 5, 7, 12, 12]
        print(bestWeek)
        let bestSum = getValuesForLine(values: bestWeek)
        print(bestSum)
        var dataEntries: [ChartDataEntry] = []
        var bestEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            let bestEntry = ChartDataEntry(x: Double(i), y: bestSum[i])
            bestEntries.append(bestEntry)
        }
        
        let dataSet = LineChartDataSet(values: dataEntries, label: "Total completed challenges per week")
        dataSet.valueFormatter = BarChartValueFormatter()
        let bestSet = LineChartDataSet(values: bestEntries, label: "Best total of completed challenges per week")
        bestSet.valueFormatter = BarChartValueFormatter()
        bestSet.setCircleColor(UIColor.red)
        bestSet.setColor(UIColor.red)
        let data = LineChartData(dataSets:  [dataSet, bestSet])
        
        cell.lineChartView.xAxis.removeAllLimitLines()
        cell.lineChartView.xAxis.valueFormatter = LineXAxisFormatter()
        cell.lineChartView.data = data
        cell.lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        return cell
    }
    
    func getValuesForLine(values: [Double]) -> [Double] {
        var points: [Double] = []
        var sum: Double = 0
        for value in values {
            sum += value
            points.append(sum)
        }
        return points
    }
    
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

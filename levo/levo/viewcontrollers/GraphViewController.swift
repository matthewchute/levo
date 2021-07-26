//
//  GraphViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-26.
//

import UIKit
import Charts
import TinyConstraints

class GraphViewController: UIViewController, ChartViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
        // charts
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        setData(data: UserData.tempUpVel, axis: "Upward Velocity")

    }
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    // Charts Methods:
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false
        
        // Y-Axis customization. No need
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.xAxis.labelTextColor = .white
        
        chartView.animate(xAxisDuration: 2.5)
        return chartView
    }()
    
    func setData(data: [Float], axis: String) {
        let set1 = LineChartDataSet(entries: prepValues(data), label: axis)
        let data = LineChartData(dataSet: set1)
        lineChartView.data = data
        data.setDrawValues(false)
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
    }
    
    func prepValues(_ input: [Float]) -> [ChartDataEntry] {
        var temp: [ChartDataEntry] = []
        if input.count == 0 {return [ChartDataEntry(x:0.0, y: 0.0)]}
        else {
            for i in 0...input.count-1 {
                temp.append(ChartDataEntry(x: Double(i), y: Double(input[i])))
                // print("x: \(Double(i)), y: \(Double(input[i]))")
            }
        }
        return temp
    }
    

}

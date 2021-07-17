
//  ViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-06-21.
//
import UIKit
import Charts
import TinyConstraints

class ViewController: UIViewController, ChartViewDelegate {
    
    var xAcc: [Float] = [3.0]
    var yAcc: [Float] = [3.0]
    var zAcc: [Float] = [3.0]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(catchX(_:)), name: Notification.Name("xdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchY(_:)), name: Notification.Name("ydata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchZ(_:)), name: Notification.Name("zdata"), object: nil)
        btn.setTitle("Start", for: .normal)
        xBtn.setTitle("X Data", for: .normal)
        yBtn.setTitle("Y Data", for: .normal)
        zBtn.setTitle("Z Data", for: .normal)
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
    }
    
    @objc func catchX(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        xAcc = arr ?? [2.0]
        print("catch x!")
    }
    
    @objc func catchY(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        yAcc = arr ?? [2.0]
        print("catch y!")
    }
    
    @objc func catchZ(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        zAcc = arr ?? [2.0]
        print("catch z!")
    }
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var yBtn: UIButton!
    @IBOutlet weak var zBtn: UIButton!
    
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "Results") as! ResultsViewController
        present(vc, animated: true)
    }
    
    @IBAction func displayXData() {
        setData(data: xAcc, axis: "X Acceleration")
    }
    
    @IBAction func displayYData() {
        setData(data: yAcc, axis: "Y Acceleration")
    }
    
    @IBAction func displayZData() {
        setData(data: zAcc, axis: "Z Acceleration")
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        
    }
    
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
                print("x: \(Double(i)), y: \(Double(input[i]))")
            }
        }
        return temp
    }

}

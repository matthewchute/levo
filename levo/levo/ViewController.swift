
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
        NotificationCenter.default.addObserver(self, selector: #selector(catchNoti(_:)), name: Notification.Name("array"), object: nil)
        arr_label.text = "No Data"
        btn.setTitle("Start", for: .normal)
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
    }
    
    @objc func catchNoti(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        xAcc = arr ?? [2.0]
        print("catch!")
        arr_label.text = "Workout Complete"
        setData()
    }
    
    @IBOutlet weak var arr_label: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "Results") as! ResultsViewController
        present(vc, animated: true)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: prepValues(xAcc), label: "x-Acceleration")
        
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


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
    
    var sample_period: Float = 0.0
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var yBtn: UIButton!
    @IBOutlet weak var zBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(catchX(_:)), name: Notification.Name("xdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchY(_:)), name: Notification.Name("ydata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchZ(_:)), name: Notification.Name("zdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchSP(_:)), name: Notification.Name("sample"), object: nil)
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
    
    @objc func catchSP(_ noti: Notification) {
        let tsp = noti.object as! Float?
        sample_period = tsp ?? 2.0
        print("catch sp!")
    }
    
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
    
    //    func process_data(xData: [Float]) -> Void {
    //        var velX = trap_rule(data: xData)
    //    }
        
    // trapezoid rule
    func trap_rule(data: [Float]) -> [Float] {
        var integral: [Float] = []
        var prev:Float = 0.0
        var area:Float = 0.0
        for i in 0...data.count-1 {
            area = (sample_period/2)*(data[i]+data[i+1])
            integral.append(area+prev)
            prev += area
        }
        integral.append(integral[data.count-1])
        return integral
    }
    
    // matrix transpose
    func tpose(_ a: [[Float]]) -> [[Float]] {
        let rows_a = a.count
        let cols_a = a[0].count
        var atrans: [[Float]] = []
        for ca in 0...cols_a {
            var temp_row: [Float] = []
            for ra in 0...rows_a {
                temp_row.append(a[ra][ca])
            }
            atrans.append(temp_row)
        }
        return atrans
    }
    
    // matrix multiply
    func matx(_ a:[[Float]], _ b:[[Float]]) -> [[Float]] {
        var c:[[Float]] = []
        let rows_a = a.count
        let cols_a = a[0].count
        let cols_b = b[0].count
        for ra in 0...rows_a {
            var temp_row: [Float] = []
            for cb in 0...cols_b {
                var temp_ele:Float = 0.0
                for ca in 0...cols_a {
                    temp_ele += a[ra][ca]*b[ca][cb]
                }
                temp_row.append(temp_ele)
            }
            c.append(temp_row)
        }
        return c
    }
    
    // inverse 2d matrix
    func inv2(_ a:[[Float]]) -> [[Float]] {
        var b:[[Float]] = []
        b.append([a[1][1], -1*a[0][1]])
        b.append([-1*a[1][0], a[0][0]])
        let determinant:Float = 1/(a[0][0]*a[1][1]-a[1][0]*a[0][1])
        b[0][0] = determinant*b[0][0]
        b[0][1] = determinant*b[0][1]
        b[1][0] = determinant*b[1][0]
        b[1][1] = determinant*b[1][1]
        return b
    }
    
    // pad vector with 1's
    func pad1(_ a:[Float]) -> [[Float]] {
        var b:[Float] = []
        var c:[Float] = []
        var d:[[Float]] = []
        for i in 0...a.count {
            b.append(a[i])
            c.append(1.0)
        }
        d.append(b)
        d.append(c)
        return d
    }
    
    func polyfit(_ a:[[Float]], _ y:[[Float]]) -> [[Float]] {
        var temp1: [[Float]] = matx(a, tpose(a))
        temp1 = inv2(temp1)
        let temp2 = matx(a, tpose(y))
        let coeffs = matx(temp1, temp2)
        return coeffs
    }
    
    func noise_comp(metric: [Float], loop:Int) -> Void {

    }

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
                print("x: \(Double(i)), y: \(Double(input[i]))")
            }
        }
        return temp
    }
}

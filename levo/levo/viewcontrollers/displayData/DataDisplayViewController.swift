//
//  DataDisplayViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-28.
//

import UIKit
import Charts
import TinyConstraints

class DataDisplayViewController: UIViewController, ChartViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = "Set #\(UserData.whichSet+1)"

        // Do any additional setup after loading the view.
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
        // charts
        chart.backgroundColor = .systemBlue
        chart.rightAxis.enabled = false
        let yAxis = chart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.setLabelCount(6, force: false)
        chart.xAxis.labelTextColor = .white
        chart.animate(xAxisDuration: 2.5)
        setData(data: UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].upVelData, axis: "Upward Velocity (m/s)")
        
        // update label
        var velPeaksVals: String = ""
        var velAvgsVals: String = ""
        for i in 0..<UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].peakVel.count {
            if i == UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].peakVel.count-1 {
                velPeaksVals.append("\(String(format: "%.2f", UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].peakVel[i]))")
                velAvgsVals.append("\(String(format: "%.2f", UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].avgVel[i]))")
            } else {
                velPeaksVals.append("\(String(format: "%.2f", UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].peakVel[i])),   ")
                velAvgsVals.append("\(String(format: "%.2f", UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].avgVel[i])),   ")
            }
        }
        mainLbl.attributedText = makeFont1("# of Reps:\n", "\(UserData.past_exer[UserData.whichCell].sets[UserData.whichSet].reps)", "\n\nAverage Velocity per Rep (m/s):\n", "\(velAvgsVals)", "\n\nPeak Velocity per Rep (m/s):\n", "\(velPeaksVals)", "", "")
        mainLbl.textAlignment = .left

    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var chart: LineChartView!
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func makeFont1(_ first: String, _ second: String, _ third: String, _ fourth: String, _ fifth: String, _ sixth: String, _ seventh: String, _ eigth: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .regular)]
        let firstStr = NSMutableAttributedString(string: first, attributes: bold)
        let secondStr = NSMutableAttributedString(string: second, attributes: regular)
        let thirdStr = NSMutableAttributedString(string: third, attributes: bold)
        let fourthStr = NSMutableAttributedString(string: fourth, attributes: regular)
        let fifthStr = NSMutableAttributedString(string: fifth, attributes: bold)
        let sixthStr = NSMutableAttributedString(string: sixth, attributes: regular)
        let seventhStr = NSMutableAttributedString(string: seventh, attributes: bold)
        let eigthStr = NSMutableAttributedString(string: eigth, attributes: regular)
        seventhStr.append(eigthStr)
        seventhStr.append(firstStr)
        seventhStr.append(secondStr)
        seventhStr.append(thirdStr)
        seventhStr.append(fourthStr)
        seventhStr.append(fifthStr)
        seventhStr.append(sixthStr)
        return seventhStr
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData(data: [Float], axis: String) {
        let set1 = LineChartDataSet(entries: prepValues(data), label: axis)
        let data = LineChartData(dataSet: set1)
        chart!.data = data
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

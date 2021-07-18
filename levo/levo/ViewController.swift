
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
    var xVel: [Float] = [3.0]
    var yVel: [Float] = [3.0]
    var zVel: [Float] = [3.0]
    var up_vel_iso_graph: [Float] = [3.0]
    var agl2gndX: [Float] = [3.0]
    var agl2gndY: [Float] = [3.0]
    var agl2gndZ: [Float] = [3.0]
    var velAvgs: [Float] = [3.0]
    var velPeaks: [Float] = [3.0]
    var accAvgs: [Float] = [3.0]
    var accPeaks: [Float] = [3.0]
    var num_reps: Int = 0
    var range_of_reps: [[Int]] = [[3]]
    var sample_period: Float = 3.0
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var yBtn: UIButton!
    @IBOutlet weak var zBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nc observers
        NotificationCenter.default.addObserver(self, selector: #selector(catchX(_:)), name: Notification.Name("xdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchY(_:)), name: Notification.Name("ydata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchZ(_:)), name: Notification.Name("zdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchAglX(_:)), name: Notification.Name("xagl"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchAglY(_:)), name: Notification.Name("yagl"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchAglZ(_:)), name: Notification.Name("zagl"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchSP(_:)), name: Notification.Name("sample"), object: nil)
        
        // buttons
        btn.setTitle("Start", for: .normal)
        xBtn.setTitle("Upward Vel", for: .normal)
        yBtn.setTitle("Y Data", for: .normal)
        zBtn.setTitle("Z Data", for: .normal)
        
        // charts
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
    }
    
    @objc func catchX(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        xAcc = arr ?? [2.0]
        print("******* Processing Data *******")
    }
    
    @objc func catchY(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        yAcc = arr ?? [2.0]
    }
    
    @objc func catchZ(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        zAcc = arr ?? [2.0]
    }
    
    @objc func catchAglX(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        agl2gndX = arr ?? [2.0]
    }
    
    @objc func catchAglY(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        agl2gndY = arr ?? [2.0]
    }
    
    @objc func catchAglZ(_ noti: Notification) {
        let arr = noti.object as! [Float]?
        agl2gndZ = arr ?? [2.0]
    }
    
    @objc func catchSP(_ noti: Notification) {
        let tsp = noti.object as! Float?
        sample_period = tsp ?? 2.0
    }
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "Results") as! ResultsViewController
        present(vc, animated: true)
    }
    
    @IBAction func displayXData() {
        (num_reps, velAvgs, velPeaks, accAvgs, accPeaks, range_of_reps) = process_data()
        setData(data: up_vel_iso_graph, axis: "Upward Velocity")
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
    
    func process_data() -> (Int, [Float], [Float], [Float], [Float], [[Int]]) {
        // xVel = noise_comp(trap_rule(xAcc), xAcc.count)
        yVel = noise_comp(trap_rule(yAcc), yAcc.count)
        zVel = noise_comp(trap_rule(zAcc), zAcc.count)
        let up_acc = orientation_correction([yAcc],[zAcc],[agl2gndY],[agl2gndZ])
        let up_vel = orientation_correction([yVel],[zVel],[agl2gndY],[agl2gndZ])
        
        //let up_dis = trap_rule(up_vel)
        
        var lwr: Int = 0
        var upr: Int = 0
        var up_acc_iso: [Float] = [0.0]
        //var up_dis_iso: [Float] = [0.0]
        //var burn:  [Float] = [0.0]
        
        (lwr, upr) = set_range(up_acc)
        (up_vel_iso_graph, up_acc_iso) = in_rep_slope(lwr, upr, up_vel, up_acc)
        //(up_dis_iso,burn) = in_rep_slope(lwr,upr,up_dis,up_vel)
            
        return rep_count(up_vel_iso_graph, up_acc_iso)
    }
        
    // trapezoid rule
    func trap_rule(_ data: [Float]) -> [Float] {
        var integral: [Float] = []
        var prev:Float = 0.0
        var area:Float = 0.0
        print("\(data.count)")
        for i in 0...data.count-2 {
            area = (sample_period/2000)*(data[i]+data[i+1]) // divide by 2000 because in seconds, not milliseconds
            integral.append(area+prev)
            prev += area
        }
        integral.append(integral[data.count-2])
        return integral
    }
    
    // matrix transpose
    func tpose(_ a: [[Float]]) -> [[Float]] {
        let rows_a = a.count-1
        let cols_a = a[0].count-1
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
        let rows_a = a.count-1
        let cols_a = a[0].count-1
        let cols_b = b[0].count-1
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
        for i in 0...a.count-2 {
            b.append(a[i])
            c.append(1.0)
        }
        d.append(b)
        d.append(c)
        return d
    }
    
    // polyfit
    func polyfit(_ a:[[Float]], _ y:[[Float]]) -> [[Float]] {
        var temp1: [[Float]] = matx(a, tpose(a))
        temp1 = inv2(temp1)
        let temp2 = matx(a, tpose(y))
        let coeffs = matx(temp1, temp2)
        return coeffs
    }
    
    // account for noise in accelerometer
    func noise_comp(_ metric: [Float], _ loop:Int) -> [Float] { // metric is uncorrected data
        var s: [Float] = []
        for i in 1...loop {
            s.append(Float(i))
        }
        let mCoeff = polyfit(pad1(s), [metric])
        var mCorrected: [Float] = []
        for i in 0...s.count-1 {
            mCorrected.append(metric[i] - s[i]*mCoeff[0][0] - mCoeff[1][0])
        }
        return mCorrected
    }
    
    // calculate sin values of a vector
    func matSin(_ agl: [[Float]], _ c: Float) -> [Float] {
        var vals: [Float] = []
        for i in 0...agl[0].count-1 {
            vals.append(sin(agl[0][i] + c))
        }
        return vals
    }
    
    // determine which direction is ground assuming x and y and directions of interest
    func orientation_correction(_ spatialX: [[Float]], _ spatialY: [[Float]], _ aglX: [[Float]], _ aglY: [[Float]]) -> [Float] {
        let sinX: [Float] = matSin(aglX, 22/14)
        let sinY: [Float] = matSin(aglY, 22/14)
        var perp2gnd: [Float] = []
        for i in 0...spatialX[0].count-1 {
            perp2gnd.append(spatialX[0][i]*sinX[i]+spatialY[0][i]*sinY[i])
        }
        return perp2gnd
    }
    
    // paramaters: index range of importance, metric of interest and its first derrivitive
    func in_rep_slope(_ lwr: Int, _ upr: Int, _ met: [Float], _ dmet_dt: [Float]) -> ([Float], [Float]) {
        if upr >= met.count || lwr >= met.count {
            return (met, dmet_dt)
        }
        
        var repsMet: [Float] = []
        var repsDmet_dt: [Float] = []
        var first_move: Int = 1
        var shift: Float = 0.0
        var prev: Float = met[lwr]
        var discon_const: Float = 0.0
        
        repsMet.append(met[lwr])
        repsDmet_dt.append(dmet_dt[lwr])
        
        for i in 1...(upr-lwr-1) {
            if 0.4 > abs(met[i+lwr] - met[i+lwr-1]) {
                repsMet.append(met[i+lwr]+discon_const)
                repsDmet_dt.append(met[i+lwr]+discon_const)
            } else {
                discon_const = met[i+lwr] - met[i+lwr-1]
                repsMet.append(met[i+lwr]+discon_const)
                repsDmet_dt.append(dmet_dt[i+lwr]+discon_const)
            }
        }
        
        let reps_met: [[Float]] = [repsMet]
        var n: [Float] = []
        var repCoeff: [[Float]] = []
        
        for i in 0...reps_met[0].count {
            n.append(Float(i))
        }
        
        if reps_met.count != 0 {
            repCoeff = polyfit(pad1(n), reps_met)
        } else {
            return (repsMet, repsDmet_dt)
        }
        
        var metCorrected: [Float] = []
        
        for i in 0...reps_met[0].count-1 {
            metCorrected.append(reps_met[0][i] - n[i]*repCoeff[0][0] - repCoeff[1][0])
        }
        
        prev = 0.0
        
        for i in 1...metCorrected.count-1 {
            if abs(prev) < 0.2 && abs(dmet_dt[i+lwr-1]) < 0.2 && abs(dmet_dt[i+lwr+1]) < 0.2 && abs(dmet_dt[i+lwr+2]) < 0.2 && abs(dmet_dt[i+lwr+3]) < 0.2 && abs(dmet_dt[i+lwr+4]) < 0.2 {
                metCorrected[i] = 0.0
                first_move = 1
                prev = metCorrected[i]
            } else if abs(dmet_dt[i+lwr-1]) < 0.2 && abs(dmet_dt[i+lwr+1]) < 0.2 && abs(dmet_dt[i+lwr+2]) < 0.2 && abs(dmet_dt[i+lwr+3]) < 0.2 && abs(dmet_dt[i+lwr+4]) < 0.2 {
                metCorrected[i] = prev
                first_move = 1
            } else {
                if first_move == 1 {
                    shift = prev - metCorrected[i]
                    first_move = 0
                    metCorrected[i] = metCorrected[i] + shift
                    prev = metCorrected[i]
                } else {
                    metCorrected[i] = metCorrected[i] + shift
                    prev = metCorrected[i]
                }
            }
        }
        return (metCorrected,repsDmet_dt)
    }
    
    // determine the range of a repetition
    func set_range(_ acc: [Float]) -> (Int, Int) {
        var idx_start:Int  = 1000000
        var idx_end: Int = 0
        for i in 0...acc.count-1 {
            if acc[i] > 0.3 || acc[i] < -0.3 {
                if i < idx_start {
                    idx_start = i
                } else if i > idx_end {
                    idx_end = i
                }
            }
        }
        return (idx_start, idx_end)
    }
    
    // determine the velocity of a repetition
    func repVelo(_ idx_low: Int, _ idx_high: Int, _ vel: [Float]) -> (Float, Float) {
        if idx_low == idx_high {
            return (0.0, 0.0)
        }
        var tempVel: [Float] = []
        for i in 0...(idx_high-idx_low) {
            tempVel.append(vel[i+idx_low])
        }
        let maxVel: Float = tempVel.max() ?? 0.0
        let meanVel: Float = tempVel.reduce(0, +) / Float(tempVel.count)
        
        return (maxVel, meanVel)
    }
    
    // count the number of repetitions
    func rep_count(_ vel: [Float], _ acc: [Float]) -> (Int, [Float], [Float], [Float], [Float], [[Int]]) {
        var rep: Int = 0
        var repetitions: Int = 0
        var t1_flag: Int = 0
        var t2_flag: Int = 0
        var t1_idx: Int = 0
        var t2_idx: Int = 0
        var veloAvgs: [Float] = []
        var veloPeaks: [Float] = []
        var accAvgs: [Float] = []
        var accPeaks: [Float] = []
        var repRange: [[Int]] = []
        
        for i in 0...vel.count-2 {
            var lwr_sign: Int = 1 - Int(truncating: NSNumber(value: vel[i] <= 0))
            let upr_sign: Int = 1 - Int(truncating: NSNumber(value: vel[i+1] <= 0))
            if i == 0 {
                let ins0: Int = 1 - Int(truncating: NSNumber(value: vel[i] <= 0))
                let ins10: Int = 1 - Int(truncating: NSNumber(value: vel[i+1] <= 0))
                let temp: [Int] = [ins0, ins10]
                if temp.min() == 1 {
                    lwr_sign = 0
                } else if temp.max() == 0 {
                    lwr_sign = 1
                }
            }
            
            if lwr_sign != upr_sign {
                rep += 1
                if t1_flag == 0 && upr_sign > 0 {
                    t1_idx = i + 1
                    t1_flag = 1
                } else if t1_flag == 1 {
                    t2_idx = i
                    t2_flag = 1
                }
            }
            
            if t1_flag == 1 && t2_flag == 1 && (t2_idx - t1_idx) > 75 {
                var avgTempVel: Float = 0.0
                var peakTempVel: Float = 0.0
                var avgTempAcc: Float = 0.0
                var peakTempAcc: Float = 0.0
                (avgTempVel, peakTempVel) = repVelo(t1_idx, t2_idx, vel)
                (avgTempAcc, peakTempAcc) = repVelo(t1_idx, t2_idx, acc)
                veloAvgs.append(avgTempVel)
                accAvgs.append(avgTempAcc)
                veloPeaks.append(peakTempVel)
                accPeaks.append(peakTempAcc)
                t1_flag = 0
                t2_flag = 0
                repRange.append([t1_idx, t2_idx])
                repetitions += 1
            } else if t1_flag == 1 && t2_flag == 1 {
                t1_flag = 0
                t2_flag = 0
            }
        }
        
        return (repetitions, veloAvgs, veloPeaks, accAvgs, accPeaks, repRange)
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

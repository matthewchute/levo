
//  ViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-06-21.
//
import UIKit
import Charts
import TinyConstraints

class WorkoutViewController: UIViewController, ChartViewDelegate {
    
    var dp = DataProcessing()
    
    // acceleration
    var xAcc: [Float] = [3.0]
    var yAcc: [Float] = [3.0]
    var zAcc: [Float] = [3.0]
    var accAvgs: [Float] = [3.0]
    var accPeaks: [Float] = [3.0]
    
    // velocity
    var xVel: [Float] = [3.0]
    var yVel: [Float] = [3.0]
    var zVel: [Float] = [3.0]
    var up_vel_iso: [Float] = [3.0]
    var velAvgs: [Float] = [3.0]
    var velPeaks: [Float] = [3.0]
    
    // gyro and angle
    var xGyro: [Float] = [3.0]
    var yGyro: [Float] = [3.0]
    var zGyro: [Float] = [3.0]
    var agl2gndX: [Float] = [3.0]
    var agl2gndY: [Float] = [3.0]
    var agl2gndZ: [Float] = [3.0]

    // other data
    var num_reps: Int = 0
    var range_of_reps: [[Int]] = [[3]]
    var sample_period: Float = 3.0
    
    var temp: [Float] = [3.0]
    var temp1: [Float] = [3.0]
    
    // UI
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var yBtn: UIButton!
    @IBOutlet weak var zBtn: UIButton!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var cBtn: UIButton!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nc observers
        NotificationCenter.default.addObserver(self, selector: #selector(catchBase(_:)), name: Notification.Name("baseData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchGyro(_:)), name: Notification.Name("gyroData"), object: nil)
        
        // buttons
        btn.setTitle("Start", for: .normal)
        xBtn.setTitle("Up Vel", for: .normal)
        yBtn.setTitle("X Acc", for: .normal)
        zBtn.setTitle("Z Acc", for: .normal)
        aBtn.setTitle("Net Disp", for: .normal)
        bBtn.setTitle("Y Gyro", for: .normal)
        cBtn.setTitle("Angular Disp XZ", for: .normal)
        dataLbl.text = "Data to be displayed here"
        
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
        // charts
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
    }
    
    @objc func catchBase(_ noti: Notification) {
        if let (arrx, arry, arrz, aglx, agly, aglz, tsp) = noti.object as! ([Float], [Float], [Float], [Float], [Float], [Float], Float)? {
            xAcc = arrx
            yAcc = arry
            zAcc = arrz
            agl2gndX = aglx
            agl2gndY = agly
            agl2gndZ = aglz
            sample_period = tsp
        } else {print("******ERROR******")}
    }
    
    @objc func catchGyro(_ noti: Notification) {
        if let (arrx, arry, arrz) = noti.object as! ([Float], [Float], [Float])? {
            xGyro = arrx
            yGyro = arry
            zGyro = arrz
        } else {print("******ERROR******")}
    }
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "BLE") as! BLEViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func displayXData() {
        if xAcc.count != 1 {
            (num_reps, velAvgs, velPeaks, accAvgs, accPeaks, range_of_reps) = process_data()
            dataLbl.text = "R: \(num_reps) \n aV: \(velAvgs) \n pV: \(velPeaks)"
        }
        setData(data: up_vel_iso, axis: "Up Vel")
    }
    
    @IBAction func displayYData() {
        setData(data: xAcc, axis: "X Acc")
    }
    
    @IBAction func displayZData() {
        setData(data: zAcc, axis: "Z Acc")
    }
    
    @IBAction func displayAData() {
        setData(data: temp1, axis: "Up Disp")
    }
    
    @IBAction func displayBData() {
        setData(data: yGyro, axis: "Y Gyro")
    }
    
    @IBAction func displayCData() {
        setData(data: temp, axis: "Ang Disp XZ")
    }
    
    @IBAction func didTapBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
        
    }
    
    func process_data() -> (Int, [Float], [Float], [Float], [Float], [[Int]]) {
        
        //let angularDispXZPlane: [Float] = dp.noise_comp(dp.trap_rule(dp.gyro_smooth(yGyro), sample_period), yGyro.count)
                
        let angularDispXZPlane: [Float] = dp.trap_rule(dp.gyro_smooth(yGyro), sample_period)
                
        //agldisp = angularDispXZPlane
        let gyro_filt = dp.gyro_crush_acc(yGyro, accAx1: zAcc, accAx2: xAcc)
                
        let agl_adjZ = dp.gyro_comb_angle(gyro: angularDispXZPlane, agl2gnd: agl2gndZ)
        let agl_adjX = dp.gyro_comb_angle(gyro: angularDispXZPlane, agl2gnd: agl2gndX)
        // get velocity in each axis
        xVel = dp.noise_comp(dp.trap_rule(xAcc, sample_period), xAcc.count)
        //yVel = noise_comp(trap_rule(yAcc), yAcc.count)
        zVel = dp.noise_comp(dp.trap_rule(zAcc, sample_period), zAcc.count)
        
        // get upward acc and vel
        let up_acc = dp.orientation_correction([xAcc],[zAcc],[agl_adjX],[agl_adjZ])
        let up_vel = dp.orientation_correction([xVel],[zVel],[agl_adjX],[agl_adjZ])
        
        // get and return rest of data
        var lwr: Int = 0
        var upr: Int = 0
        var up_acc_iso: [Float] = [0.0]
        (lwr, upr) = dp.set_range(up_acc)
        (up_vel_iso, up_acc_iso) = dp.in_rep_slope(lwr, upr, up_vel, up_acc)
        
        
        
        let netDisp = dp.noise_comp(dp.trap_rule(up_vel_iso, sample_period), up_vel_iso.count)
        
        temp = agl_adjZ
        temp1 = gyro_filt
            
        return dp.rep_count(up_vel_iso, up_acc_iso)
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

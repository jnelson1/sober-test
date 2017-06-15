//
//  ViewController.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/12/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var motion = CMMotionManager()
    var timer = Timer()
    var magnitudes: [Double] = []
    var magAvg: Double?
    var result: Bool?
    var isStartButton = true
    var isCalibration = false
    let controlObject = Control.shared

    @IBOutlet weak var calibrateButton: UIButton!
    
    @IBOutlet weak var soberScore: UILabel!
    
    @IBAction func startstopTest(_ sender: Any) {
        if controlObject.controlAcc==0.0 && isCalibration==false
        {
            let alert = UIAlertController(title: "You must first provide a sober baseline", message: "press 'calibrate' and then continue with test", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                // perhaps use action.title here
                
            })
            self.present(alert, animated: true)
        }
        else{
        if isStartButton{
            magnitudes=[]
            self.startAccelerometers()
            isStartButton = false
            (sender as AnyObject).setImage!(UIImage(named: "pause-button.png")!, for: [])

        }
        else{
            self.motion.stopAccelerometerUpdates()
            self.motion.stopDeviceMotionUpdates()
            if isCalibration{
                controlObject.controlAcc = magAvg!
            }
            isStartButton=true
            if isCalibration{
            performSegue(withIdentifier: "navToCalibration", sender: Any?.self)
                isCalibration = false
                self.calibrateButton.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                (sender as AnyObject).setImage!(UIImage(named: "play-button.png")!, for: [])

                
            }
            else{
            performSegue(withIdentifier: "BalanceTestToResults", sender: Any?.self)
                (sender as AnyObject).setImage!(UIImage(named: "play-button.png")!, for: [])
            }
        }
        }
    }
    
    @IBAction func Calibration(_ sender: Any) {
        isCalibration = true
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.calibrateButton.backgroundColor=color
    }
    override func viewWillDisappear(_ animated: Bool) {
        motion.stopDeviceMotionUpdates()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    func startAccelerometers() {
            // Make sure the accelerometer hardware is available.
            if self.motion.isAccelerometerAvailable {
                self.motion.accelerometerUpdateInterval = 1.0 / 2.0  // 60 Hz
                //self.motion.startAccelerometerUpdates()
                
                // Configure a timer to fetch the data.
                self.timer = Timer(fire: Date(), interval: (1.0/2.0), repeats: true, block: { (timer) in
                    // Get the accelerometer data.
                    /*
                    if let data = self.motion.accelerometerData {
                        let x = data.acceleration.x
                        let y = data.acceleration.y
                        let z = data.acceleration.z
 */
                 self.motion.startDeviceMotionUpdates(to: .main) {
                    [weak self] (data: CMDeviceMotion?, error: Error?) in
                        if let acc = data?.userAcceleration{
                            let x = acc.x
                            let y = acc.y
                            let z = acc.z
                    

                        // Use the accelerometer data in your app.
                        
                        let magnitude = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
                        self?.magnitudes.append(magnitude)
                        self?.magAvg = self?.average(magnitudes: (self?.magnitudes)!)
                            var redColor = 0.0
                              var greenColor = 0.0
                             if ((self?.magAvg!)!-(self?.controlObject.controlAcc)!) > Double(0.01){
                                    redColor = 1.0
                                    greenColor = 0.0
                             }
                             else{
                             if ((self?.magAvg!)!-(self?.controlObject.controlAcc)!)<0.0{
                                redColor = 0.0
                             greenColor = 1.0
                             }
                             redColor = 100.0*((self?.magAvg!)!-(self?.controlObject.controlAcc)!)
                             greenColor = 1.0-100.0*((self?.magAvg!)!-(self?.controlObject.controlAcc)!)
                             }
                            self?.soberScore.backgroundColor = UIColor(red: CGFloat(redColor), green: CGFloat(greenColor), blue: 0, alpha: 1)
                            self?.soberScore.text = "Sober Score = \(10-(1000*((self?.magAvg!)!-(self?.controlObject.controlAcc)!)))"
                            
                        print ("x: \(x) y: \(y) z: \(z) average: \(self?.magAvg) calVal = \(self?.controlObject.controlAcc)")
                        
                        }
                    }
                })
                
                // Add the timer to the current run loop.
                RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
            }
        }




    func average(magnitudes: [Double]) -> Double {
        
        var total = 0.0
        //use the parameter-array instead of the global variable votes
        for mag in magnitudes{
            
            total += Double(mag)
            
        }
        
        var average = total/Double(magnitudes.count)
        return average
    }
    
    func isSober() -> Bool{
        if (magAvg!-controlObject.controlAcc) > Double(0.01){
            result = false
        }
        else {
            result = true
        }
        return result!
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BalanceTestToResults"{
            let balanceResultsVC: BalanceResultsViewController=segue.destination as!BalanceResultsViewController
            balanceResultsVC.result=isSober()
    }


}
}

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
    let controlObject = Control()

    
    @IBAction func startstopTest(_ sender: Any) {
        if controlObject.controlAcc==0.0
        {
            let alert = UIAlertController(title: "You must first provide a sober baseline", message: "press 'calibrate' and then continue with test", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                // perhaps use action.title here
                
            })
            self.present(alert, animated: true)
        }
        else{
        if isStartButton{
            startDeviceMotion()
            isStartButton = false
        }
        else{
            self.motion.stopAccelerometerUpdates()
            if isCalibration{
                controlObject.controlAcc = magAvg!
            }
            isStartButton=true
            if isCalibration{
            performSegue(withIdentifier: "navToCalibration", sender: Any?.self)
                isCalibration = false
            }
            else{
            performSegue(withIdentifier: "BalanceTestToResults", sender: Any?.self)
            }
        }
        }
    }
    
    @IBAction func Calibration(_ sender: Any) {
        isCalibration = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startDeviceMotion() {
        let motion = CMMotionManager()
        
        func startAccelerometers() {
            // Make sure the accelerometer hardware is available.
            if self.motion.isAccelerometerAvailable {
                self.motion.accelerometerUpdateInterval = 1.0 / 2.0  // 60 Hz
                self.motion.startAccelerometerUpdates()
                
                // Configure a timer to fetch the data.
                self.timer = Timer(fire: Date(), interval: (1.0/2.0), repeats: true, block: { (timer) in
                    // Get the accelerometer data.
                    if let data = self.motion.accelerometerData {
                        let x = data.acceleration.x
                        let y = data.acceleration.y
                        let z = data.acceleration.z
                        
                        // Use the accelerometer data in your app.
                        
                        let magnitude = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
                        self.magnitudes.append(magnitude)
                        self.magAvg = self.average(magnitudes: self.magnitudes)
                        
                        print ("x: /(x) y: /(y) z: /(z) average: /(magAvg)")
                        
                    }
                })
                
                // Add the timer to the current run loop.
                RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
            }
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
        if (magAvg!-controlObject.controlAcc) > Double(5.0){
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

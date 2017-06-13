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
    
    @IBAction func startstopTest(_ sender: Any) {
        if isStartButton{
            startDeviceMotion()
            isStartButton = false
        }
        else{
            self.motion.stopAccelerometerUpdates()
            if isCalibration{
                let controlObject = Control()
                controlObject.controlAcc = magAvg!
            }
            isStartButton=true
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
        if magAvg! > Double(5.0){
            result = false
        }
        else {
            result = true
        }
        return result!
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }


}

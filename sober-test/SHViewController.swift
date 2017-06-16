//
//  SHViewController.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/15/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import UIKit
import CoreMotion
import RealmSwift

class SHViewController: UIViewController {
    var motion = CMMotionManager()
    var timer = Timer()
    var magnitudes: [Double] = []
    var magAvg: Double?
    var result: Bool?
    var isStartButton = true
    var isCalibration = false
    
    let realm = try! Realm()
    
    
    @IBOutlet weak var calibrateButton: UIButton!
    
    @IBOutlet weak var soberScore: UILabel!
    
    @IBAction func startstopTest(_ sender: Any) {
        let control = realm.objects(Control.self)
        
        if (control.first==nil||control.first?.controlGyro==0.0) && isCalibration==false
        {
            let alert = UIAlertController(title: "You must first provide a sober baseline", message: "press 'calibrate' and then continue with test", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                
            })
            self.present(alert, animated: true)
        }
        else{
            if isStartButton{
                magnitudes=[]
                self.startGyroscope()
                isStartButton = false
                (sender as AnyObject).setImage!(UIImage(named: "pause-button.png")!, for: [])
                
            }
            else{
                self.motion.stopDeviceMotionUpdates()
                isStartButton=true
                if isCalibration{
                    if let controlFirst = control.first{
                        try! realm.write {
                            controlFirst.controlGyro = magAvg!
                        }
                    }
                    else{
                        let control = Control()
                        control.controlGyro = magAvg!
                        try! realm.write {
                            realm.add(control)
                        }
                    }
                    performSegue(withIdentifier: "navToCalibration2", sender: Any?.self)
                    isCalibration = false
                    self.calibrateButton.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                    (sender as AnyObject).setImage!(UIImage(named: "play-button.png")!, for: [])
                    
                    
                }
                else{
                    performSegue(withIdentifier: "SteadyHandsTestToResults", sender: Any?.self)
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
    func startGyroscope() {
        // Make sure the accelerometer hardware is available.
        
        let control = realm.objects(Control.self)
        let controlFirst = control.first
        
        
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 2.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates()
            
            self.timer = Timer(fire: Date(), interval: (1.0/2.0), repeats: true, block: { (timer) in
                // Get the accelerometer data.
                
                
                if let data = self.motion.deviceMotion{
                    let x = data.attitude.pitch
                    let y = data.attitude.roll
                    let z = data.attitude.yaw
                    
                    
                    // Use the accelerometer data in your app.
                    
                    let magnitude = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
                    self.magnitudes.append(magnitude)
                    self.magAvg = self.average(magnitudes: (self.magnitudes))
                    
                    if self.isCalibration==false{
                        
                        var redColor = 0.0
                        var greenColor = 0.0
                        if ((self.magAvg)!-(controlFirst?.controlGyro)!) > Double(0.01){
                            redColor = 1.0
                            greenColor = 0.0
                        }
                        else{
                            if ((self.magAvg)!-(controlFirst?.controlGyro)!)<0.0{
                                redColor = 0.0
                                greenColor = 1.0
                            }
                            redColor = 100.0*((self.magAvg)!-(controlFirst?.controlGyro)!)
                            greenColor = 1.0-100.0*((self.magAvg)!-(controlFirst?.controlGyro)!)
                        }
                        self.soberScore.backgroundColor = UIColor(red: CGFloat(redColor), green: CGFloat(greenColor), blue: 0, alpha: 1)
                        self.soberScore.text = "Sober Score = \(10-(1000*((self.magAvg)!-(controlFirst?.controlGyro)!)))"
                    }
                    
                    print ("x: \(x) y: \(y) z: \(z) average: \(self.magAvg) calVal = \(controlFirst?.controlGyro)!")
                    
                }
                
            })
            RunLoop.current.add(self.timer, forMode: .defaultRunLoopMode)
            
            
            // Add the timer to the current run loop.
        }
    }
    
    func average(magnitudes: [Double]) -> Double {
        
        var total = 0.0
        for mag in magnitudes{
            
            total += Double(mag)
            
        }
        
        var average = total/Double(magnitudes.count)
        return average
    }
    
    func isSober() -> Bool{
        let control = realm.objects(Control.self)
        let controlFirst = control.first
        if (magAvg!-(controlFirst?.controlGyro)!) > Double(0.01){
            result = false
        }
        else {
            result = true
        }
        return result!
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SteadyHandsTestToResults"{
            let steadyHandsResultsVC: SteadyHandsResultsViewController=segue.destination as!SteadyHandsResultsViewController
            steadyHandsResultsVC.result=isSober()
        }
    }

        override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

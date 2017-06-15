//
//  ViewController.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/12/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import UIKit
import CoreMotion
import RealmSwift


class ViewController: UIViewController {
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

        if control.first==nil && isCalibration==false
        {
            let alert = UIAlertController(title: "You must first provide a sober baseline", message: "press 'calibrate' and then continue with test", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                
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
            self.motion.stopDeviceMotionUpdates()
            isStartButton=true
            if isCalibration{
                if let controlFirst = control.first{
                    try! realm.write {
                        controlFirst.controlAcc = magAvg!
                    }
                }
                else{
                    let control = Control()
                    control.controlAcc = magAvg!
                    try! realm.write {
                        realm.add(control)
                    }
                }
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
        
            let control = realm.objects(Control.self)
            let controlFirst = control.first

        
            if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 2.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates()

                self.timer = Timer(fire: Date(), interval: (1.0/2.0), repeats: true, block: { (timer) in
                    // Get the accelerometer data.
                    
 
                        if let data = self.motion.deviceMotion{
                            let x = data.userAcceleration.x
                            let y = data.userAcceleration.y
                            let z = data.userAcceleration.z
                    

                        // Use the accelerometer data in your app.
                        
                        let magnitude = sqrt(pow(x,2)+pow(y,2)+pow(z,2))
                        self.magnitudes.append(magnitude)
                        self.magAvg = self.average(magnitudes: (self.magnitudes))
                            
                            if self.isCalibration==false{
                            
                            var redColor = 0.0
                              var greenColor = 0.0
                             if ((self.magAvg)!-(controlFirst?.controlAcc)!) > Double(0.01){
                                    redColor = 1.0
                                    greenColor = 0.0
                             }
                             else{
                             if ((self.magAvg)!-(controlFirst?.controlAcc)!)<0.0{
                                redColor = 0.0
                             greenColor = 1.0
                             }
                             redColor = 100.0*((self.magAvg)!-(controlFirst?.controlAcc)!)
                             greenColor = 1.0-100.0*((self.magAvg)!-(controlFirst?.controlAcc)!)
                             }
                            self.soberScore.backgroundColor = UIColor(red: CGFloat(redColor), green: CGFloat(greenColor), blue: 0, alpha: 1)
                            self.soberScore.text = "Sober Score = \(10-(1000*((self.magAvg)!-(controlFirst?.controlAcc)!)))"
                            }
                            
                        print ("x: \(x) y: \(y) z: \(z) average: \(self.magAvg) calVal = \(controlFirst?.controlAcc)!")
                        
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
        if (magAvg!-(controlFirst?.controlAcc)!) > Double(0.01){
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

//
//  SteadyHandsResultsViewController.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/15/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import UIKit

class SteadyHandsResultsViewController: UIViewController {
    var result: Bool?
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var resultsImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if result!{
            resultsLabel.text = "sober!"
            resultsImage.image = UIImage(named: "smile.jpeg")
        }
        else{
            resultsLabel.text = "drunk!"
            resultsImage.image = UIImage(named: "drunk-1.jpeg")
            
        }
        

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

//
//  BalanceResultsViewController.swift
//  sober-test
//
//  Created by Jon Nelson1 on 6/13/17.
//  Copyright © 2017 Jon Nelson. All rights reserved.
//

import UIKit

class BalanceResultsViewController: UIViewController {
    var result: Bool?
    @IBOutlet weak var resultsLabelTextField: UILabel!
    
    @IBOutlet weak var resultsImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if result!{
            resultsLabelTextField.text = "sober!"
            resultsImageView.image = UIImage(named: "smile.jpeg")
        }
        else{
            resultsLabelTextField.text = "drunk!"
            resultsImageView.image = UIImage(named: "drunk.jpeg")

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

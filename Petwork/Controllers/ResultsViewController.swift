//
//  ResultsViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit

class ResultsViewController: UIViewController {
    var searchTerm: String = ""
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.text = "Results for \(searchTerm)"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

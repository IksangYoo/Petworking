//
//  SearchViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit

class SearchViewController: UIViewController {
    var pressedSearchTerm: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        pressedSearchTerm = sender.currentTitle!
        performSegue(withIdentifier: "goToResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            let destinationVC = segue.destination as! ResultsViewController
            destinationVC.searchTerm = pressedSearchTerm
        }
    }
    
}

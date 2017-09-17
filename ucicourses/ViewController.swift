//
//  ViewController.swift
//  ucicourses
//
//  Created by Vatsal Rustagi on 9/5/17.
//  Copyright © 2017 Vatsalr23. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, BackendDelegate {
    
    let backend = Backend()

    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var coursesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backend.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        courseField.text = selectedCourses.joined(separator: ", ")
        if courseField.text?.isEmpty == true{
            coursesLabel.text = ""
        }
    }
    
    @IBAction func submitBtn(_ sender: UIButton) {
        if let courses = courseField.text{
            let params = ["courses": courses.components(separatedBy: ", ")]
            backend.postJSONData(to: "", withParams: params)
        }
        view.endEditing(true)
    }
    
    func processDataOfType(JSON: Dictionary<String, Any>) {
        if let list = JSON["result"] as? [String]{
            let result = "You can take: " + list.joined(separator: ", ")
            coursesLabel.text = result
        }
    }

}


//
//  CoursesTakenVC.swift
//  ucicourses
//
//  Created by Vatsal Rustagi on 9/12/17.
//  Copyright © 2017 Vatsalr23. All rights reserved.
//

import UIKit

var selectedCourses = [String]()

class CoursesTakenVC: UIViewController, BackendDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var courseType: UISegmentedControl!
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        collectionView.alpha = 0.0
        current = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        backend.getJSONData(from: "listings/", withParams: ["department": current])
    }
    @IBAction func clearAll(_ sender: UIButton) {
        for (key,_) in indexes{
            indexes[key]!.removeAll()
        }
        selectedCourses.removeAll()
        
        collectionView.alpha = 0.0
        
        collectionView.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 1.0
        })
    }
    
    var courses = [String]()
    var titles = [String]()
    var indexes = [
        "ICS": [Int](),
        "CS": [Int](),
        "INF": [Int]()
    ]
    let backend = Backend()
    var current = "ICS"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backend.delegate = self
        backend.getJSONData(from: "listings/", withParams: ["department": current])
    }
    
    func processDataOfType(JSON: Dictionary<String, Any>) {
        courses = []
        titles = []
        if let result = JSON["result"] as? [Dictionary<String, String>]{
            for dict in result{
                courses.append(dict["course"]!)
                titles.append(dict["title"]!)
            }
        }
        self.collectionView.reloadData()
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 1.0
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(selectedCourses)
    }
}

extension CoursesTakenVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - 1, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCell", for: indexPath) as? CourseCell{
            cell.updateUI(course: courses[indexPath.row], name: titles[indexPath.row])
            
            if (indexes[current]?.contains(indexPath.row))!{
                cell.bgView.backgroundColor = UIColor(red: 0.50, green: 1.00, blue: 0.00, alpha: 1.00)
            }
            else{
                cell.bgView.backgroundColor = UIColor(red: 0.30, green: 0.18, blue: 0.64, alpha: 1.00)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CourseCell
        let current = courseType.titleForSegment(at: courseType.selectedSegmentIndex)!
        if (indexes[current]?.contains(indexPath.row))! {
            let i = (indexes[current]?.index(of: indexPath.row))!
            indexes[current]?.remove(at: i)
            if let j = selectedCourses.index(of: courses[indexPath.row]){
                selectedCourses.remove(at: j)
            }
            
            cell.bgView.backgroundColor = UIColor(red: 0.30, green: 0.18, blue: 0.64, alpha: 1.00)
        }
        else{
            indexes[current]?.append(indexPath.row)
            selectedCourses.append(cell.courseLabel.text!)
            cell.bgView.backgroundColor = UIColor(red: 0.50, green: 1.00, blue: 0.00, alpha: 1.00)
        }
        
    }
}

class CourseCell: UICollectionViewCell{
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var courseName: UILabel!
    
    func updateUI(course: String, name: String){
        courseLabel.text = course
        courseName.text = name
    }
}

//
//  TestViewController.swift
//  ios-poc
//
//  Created by USER on 2018. 6. 12..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBAction func click(_ sender: Any) {
        let dummyView = UIView()
        dummyView.backgroundColor = UIColor.randomColor()
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        let s = UISwitch()
        dummyView.addSubview(s)
        v.addSubview(dummyView)
        let bottomAnchor = v.subviews.count == 1 ? v.topAnchor : v.subviews[v.subviews.count - 2].bottomAnchor
        NSLayoutConstraint.activate([
            dummyView.topAnchor.constraint(equalTo: bottomAnchor , constant: v.subviews.count == 1 ? 0 : 40),
            dummyView.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 0),
            dummyView.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            dummyView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        print(v.intrinsicContentSize)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            print("didLayoutSubviews", self.v.subviews.last)
            if let lastView = self.v.subviews.last {
                let h = lastView.frame.origin.y + lastView.frame.size.height
                self.scrollView.contentSize = CGSize(width: self.v.frame.width, height: h)
            }
        }
    }
}

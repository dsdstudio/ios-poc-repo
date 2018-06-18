//
//  TestViewController.swift
//  ios-poc
//
//  Created by USER on 2018. 6. 12..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class AutolayoutScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var list:[String] = ["우아아","ㅁㅁㅁ", "ㅂㅈㄷㄱ"]

    @IBAction func click(_ sender: Any) {
        self.list.append(UUID().uuidString)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .orange
    }
}
extension AutolayoutScrollViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
}



class ResizableTableView:UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

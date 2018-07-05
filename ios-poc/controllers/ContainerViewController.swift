//
//  ContainerViewController.swift
//  ios-poc
//
//  Created by USER on 2018. 7. 4..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import RxSwift
class ContainerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    let event = PublishSubject<String>()
    weak var currentVc:UIViewController?
    

    override func viewDidLoad() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Child0") {
            vc.view.frame = self.containerView.bounds
            self.addChildViewController(vc)
            containerView.addSubview(vc.view)
            self.currentVc = vc
        }
        super.viewDidLoad()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    @IBAction func changed(_ sender: UISegmentedControl) {
        if let oldVc = self.currentVc, let vc = storyboard?.instantiateViewController(withIdentifier: "Child\(sender.selectedSegmentIndex)") {
            switchViewController(oldVc, newVc: vc)
        }
    }
    func switchViewController(_ oldVc:UIViewController, newVc:UIViewController) {
        oldVc.willMove(toParentViewController: nil)
        
        self.addChildViewController(newVc)
        newVc.view.frame = self.containerView.bounds
        self.containerView.addSubview(newVc.view)

        oldVc.view.removeFromSuperview()
        oldVc.removeFromParentViewController()
        newVc.didMove(toParentViewController: self)
        self.currentVc = newVc
    }
    
    deinit {
        print("deinit : ContainerViewController")
    }
}

class ChildA:UIViewController {
    override func viewDidLoad() {
        print("childA didload")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("diddisappear")
    }
    deinit {
        print("deinit childA")
    }
}

class ChildB:UIViewController {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        print("childB didload")
    }
    @IBAction func click(_ sender: UIButton) {
        guard !indicator.isAnimating  else {
            return
        }
        sender.isEnabled = false
        indicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.indicator.stopAnimating()
            sender.isEnabled = true
        }
    }
}

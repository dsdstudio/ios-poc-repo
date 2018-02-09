//
//  CanvasViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {
    @IBOutlet weak var canvasView: CanvasView!
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func modeSelected(_ sender: UISegmentedControl!) {
        let selectedIndex = sender.selectedSegmentIndex
        print("selectedIndex \(selectedIndex)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

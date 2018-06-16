//
//  ViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

struct TableData {
    var text:String
    var detailText:String
    var identifier:String
    var action:(_ c:ViewController, _ identifier:String) -> Void
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    static let commonFn:(_ c:ViewController, _ identifier:String) -> Void = { c, identifier in
        if let storyboard = c.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: identifier)
            c.navigationController?.pushViewController(vc, animated: true)
        }
    }
    let menu:[TableData] = [
        TableData(text: "NestedScrollViewController", detailText: "중첩된 스크롤뷰", identifier: "NestedScrollViewController", action: commonFn),
//        TableData(text: "CanvasViewController", detailText: "Drawing", identifier: "CanvasViewController", action: commonFn),
//        TableData(text: "CGPDFPageViewController", detailText: "old cgpdfPage Based view controller", identifier: "CGPDFPageViewController", action: commonFn),
        TableData(text: "PDFKitBasedPageViewController", detailText: "pdfkit Based view controller", identifier: "PDFKitBasedPageViewController", action: commonFn),
        TableData(text: "LassoViewController", detailText: "Lasso Prototyping", identifier: "LassoViewController", action: commonFn),
        TableData(text: "DraggableCollectionViewController", detailText: "collectionview dragndrop", identifier: "DraggableCollectionViewController", action: commonFn),
        TableData(text: "TestViewController", detailText: "scrollview autolayout Tets", identifier: "TestViewController", action: commonFn),
        TableData(text: "BluetoothController", detailText: "bluetooth Server And Client", identifier: "BLEViewController", action: commonFn)
    ]
    override func viewDidLoad() {
        self.title = "IOS Prototyping Lab"
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = menu[indexPath.row]
        cell.textLabel?.text = data.text
        cell.detailTextLabel?.text = data.detailText
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = menu[indexPath.row]
        data.action(self, data.identifier)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
}

//
//  CanvasViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import PDFKit

class CanvasViewController: UIViewController {
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfThumbnailView: PDFThumbnailView!
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        pdfView.backgroundColor = .darkGray
        pdfView.autoScales = true
        pdfView.minScaleFactor = 1
        pdfView.maxScaleFactor = 2
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        setupPages()
        // 호출 순서에 영향을 받는다. document 가 세팅된 이후에 호출되어야함
        pdfView.usePageViewController(true)
    }

    func setupPages() {
        let document = PDFDocument()
        document.delegate = self
        pdfView.document = document
      
        for i in 0...10 {
            addSamplePage(index: i, text: "Page \(i)")
        }
    }
    
    func addSamplePage(index:Int, text:String) {
        let page = PDFPage()
        let annotation = PDFAnnotation(bounds: CGRect(origin:CGPoint(x:50, y:50), size:CGSize(width: 200, height: 50)),
                                       forType: .freeText,
                                       withProperties: nil)
        annotation.contents = text
        annotation.color = UIColor.darkGray
        annotation.alignment = .center
        
        pdfView.document?.insert(page, at: index)
        page.addAnnotation(annotation)
    }
    
    func writeFile() {
        var fileUrl = MemesUtil.documentDirectory()
        fileUrl.appendPathComponent("t.pdf")
        
        let s = "qwerqwer"
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
            try s.write(to: fileUrl, atomically: true, encoding: .utf8)
            print("롸이트 성공")
            let t0 = try String(contentsOf:fileUrl, encoding:.utf8)
            print("파일내용:: \(t0)")
        } catch {
            
        }

    }
    @IBAction func modeSelected(_ sender: UISegmentedControl!) {
        let selectedIndex = sender.selectedSegmentIndex
        print("selectedIndex \(selectedIndex)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CanvasViewController:PDFDocumentDelegate {
    func classForPage() -> AnyClass {
        return CanvasView.self
    }
}

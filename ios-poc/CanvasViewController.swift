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
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        print(pdfView.subviews)
        setupPages()
    }

    func setupPages() {
        let document = PDFDocument()
        document.delegate = self
        pdfView.document = document
        
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.thumbnailSize = CGSize(width: 44, height: 50)
        
        for i in 0...10 {
            addSamplePage(index: i, text: "Page \(i)")
        }
    }
    
    func addSamplePage(index:Int, text:String) {
        let page = PDFPage()
        pdfView.document?.insert(page, at: index)
        let annotation = PDFAnnotation(bounds: CGRect(origin:.zero, size:CGSize(width: 200, height: 50)),
                                       forType: .freeText,
                                       withProperties: nil)
        annotation.contents = text
        annotation.color = UIColor.darkGray
        annotation.alignment = .center
        
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

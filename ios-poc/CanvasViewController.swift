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
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    override func viewDidLoad() {
        pdfView.backgroundColor = .darkGray
        pdfView.autoScales = true
        pdfView.minScaleFactor = 1
        pdfView.maxScaleFactor = 2
        setupPages()
    }

    func setupPages() {
        let document = PDFDocument()
        document.delegate = self
        pdfView.document = document
        
        // Page 생성 후 추가
        let page = PDFPage()
        document.insert(page, at: 0)
        
        let annotation = PDFAnnotation(bounds: CGRect(origin:.zero, size:CGSize(width: 200, height: 40)),
                                       forType: .ink,
                                       withProperties: nil)
        annotation.color = .red
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0, y:0))
        path.lineWidth = 3
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.addLine(to: CGPoint(x:40, y:40))
        annotation.add(path)
        
        page.addAnnotation(annotation)
        pdfView.currentPage?.addAnnotation(annotation)

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

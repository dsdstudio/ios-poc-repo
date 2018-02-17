//
//  CGPDFViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 15..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class CGPDFViewController: UIViewController {
    override func viewDidLoad() {
        print("pdfviewcontroller")
        let pdfView = SamplePDFView(frame: view.bounds)
        pdfView.backgroundColor = .orange
        view.addSubview(pdfView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class SamplePDFView :UIView {
    var pdfDocument:CGPDFDocument? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate func loadPdfFile() {
        if let pdfUrl:URL = Bundle.main.url(forResource: "arabic", withExtension: ".pdf") {
            let doc:CGPDFDocument! = CGPDFDocument(pdfUrl as CFURL)
            print("document page count :: \(doc.numberOfPages)")
            pdfDocument = doc
            if let pdfDocument = self.pdfDocument {
                // CGPDFPage는 1Page부터 시작함
                for pageIndex in 1...pdfDocument.numberOfPages {
                    let page = pdfDocument.page(at:pageIndex)
                    let pageDictionary:CGPDFDictionaryRef = (page?.dictionary!)!
                    let pageDictionaryCount = CGPDFDictionaryGetCount(pageDictionary)
                    PDFParser.scanPDF(page: page!)
                    PDFParser.parseAnnotations(pageDictionary: pageDictionary)
                    print("\(pageIndex) \(page) \(pageDictionary) \(pageDictionaryCount)")
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        loadPdfFile()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        UIColor.red.setFill()
        context.saveGState()
        
        // 뒤집힌 PDF좌표계로 조정
        context.translateBy(x: 0.0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        if let pdfDocument = self.pdfDocument {
            context.drawPDFPage(pdfDocument.page(at: 1)!)
        }
        context.restoreGState()
    }
}

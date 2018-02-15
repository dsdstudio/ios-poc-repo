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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

class SamplePDFView :UIView {
    var pdfDocument:CGPDFDocument? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate func loadPdfFile() {
        if let pdfUrl:URL = Bundle.main.url(forResource: "sample_pdf", withExtension: ".pdf") {
            let doc:CGPDFDocument! = CGPDFDocument(pdfUrl as CFURL)
            print("document page count :: \(doc.numberOfPages)")
            pdfDocument = doc
            if let pdfDocument = self.pdfDocument {
                // CGPDFPage는 1Page부터 시작함
                for i in 1...pdfDocument.numberOfPages {
                    let page = pdfDocument.page(at:i)
                    let dictionary:CGPDFDictionaryRef = (page?.dictionary!)!
                    let dictionaryCount = CGPDFDictionaryGetCount(dictionary)
                    var pageAnnotations:CGPDFArrayRef? = nil
                    if CGPDFDictionaryGetArray(dictionary, "Annots", &pageAnnotations) == true {
                        for j in 0...dictionaryCount {
                            var annotationDictionary:CGPDFDictionaryRef? = nil
                            if CGPDFArrayGetDictionary(pageAnnotations!, j, &annotationDictionary) {
                                print("annotation 받음 ... \(pageAnnotations), \(annotationDictionary)")
                            }
                        }
                    } else {
                        print("annotation 받기 실패 \(pageAnnotations)")
                    }
                    print("\(i) \(page) \(dictionaryCount)")
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
        context.fill(CGRect(origin:CGPoint(x:50, y:100), size:CGSize(width:500, height:500)))
    }
}

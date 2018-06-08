//
//  CGPDFViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 15..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

import PDFKit

class CGPDFPageViewController: UIViewController  {
    var currentIndex:Int = 0
    var pageController:UIPageViewController?
    var doc:CGPDFDocument?
    override func viewDidLoad() {
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageController?.delegate = self
        pageController?.dataSource = self
        CGPDFDocumentBasedInit()
    }
    
    func CGPDFDocumentBasedInit() {
        if let pdfUrl:URL = Bundle.main.url(forResource: "sample_pdf", withExtension: ".pdf") {
            let doc:CGPDFDocument! = CGPDFDocument(pdfUrl as CFURL)
            self.doc = doc
            print("document page count :: \(doc.numberOfPages)")
            let firstController = self.viewController(at: 0)!
            let controllers = [firstController]
            pageController?.setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
            self.addChild(self.pageController!)
            self.view.addSubview((pageController?.view)!)
            
            self.pageController?.view.frame = self.view.bounds
            pageController?.didMove(toParent: self)
        }
    }
    
    func viewController(at index:Int) -> CGPDFViewControler? {
        if doc?.numberOfPages == 0 || (doc?.numberOfPages)! <= index {
            return nil
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "CGPDFViewController") as! CGPDFViewControler
        vc.pdf = doc
        vc.pageNumber = index + 1
        return vc
    }
    
    func indexOfViewController(_ vc:CGPDFViewControler) -> Int{
        return vc.pageNumber - 1
    }
}

extension CGPDFPageViewController:UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! CGPDFViewControler)
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return self.viewController(at:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! CGPDFViewControler)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == doc?.numberOfPages {
            return nil
        }
        
        return self.viewController(at:index)
    }
}

extension CGPDFPageViewController:UIPageViewControllerDelegate {
    
}

class CGPDFViewControler: UIViewController {
    var pdf:CGPDFDocument!
    var pageNumber:Int = 0
    override func viewDidLoad() {
        let v = SamplePDFPageView(frame: view.bounds)
        v.page = pdf.page(at: pageNumber)
        v.backgroundColor = .white
        let rect = v.page?.getBoxRect(.mediaBox)
        let scale:CGFloat = v.bounds.width / (rect?.width)!
        v.pdfScale = scale
        self.view.addSubview(v)
        PDFParser.scanPDF(page: v.page!)
        PDFParser.parseAnnotations(pageDictionary: (v.page?.dictionary)!)
    }
}

class SamplePDFPageView:UIView {
    var page:CGPDFPage? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var pdfScale:CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        UIColor.red.setFill()
        context.saveGState()
        
        // 뒤집힌 PDF좌표계로 조정
        context.translateBy(x: 0.0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.scaleBy(x: pdfScale, y: pdfScale)

        if let p = self.page {
            context.drawPDFPage(p)
        }
        
        context.restoreGState()
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
                    PDFParser.scanPDF(page: page!)
                    PDFParser.parseAnnotations(pageDictionary: pageDictionary)
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

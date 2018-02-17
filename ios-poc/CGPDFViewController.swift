//
//  CGPDFViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 15..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class CGPDFViewController: UIViewController  {
    var currentIndex:Int = 0
    var pageController:UIPageViewController?
    var doc:CGPDFDocument?
    override func viewDidLoad() {
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageController?.delegate = self
        pageController?.dataSource = self
        if let pdfUrl:URL = Bundle.main.url(forResource: "sample_pdf", withExtension: ".pdf") {
            let doc:CGPDFDocument! = CGPDFDocument(pdfUrl as CFURL)
            self.doc = doc
            print("document page count :: \(doc.numberOfPages)")
            let firstController = self.viewController(at: 0)!
            let controllers = [firstController]
            pageController?.setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
            self.addChildViewController(self.pageController!)
            self.view.addSubview((pageController?.view)!)
            
            self.pageController?.view.frame = self.view.bounds
            pageController?.didMove(toParentViewController: self)
        }
    }
    
    func viewController(at index:Int) -> PDFViewControler? {
        if doc?.numberOfPages == 0 || (doc?.numberOfPages)! <= index {
            return nil
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "PDFViewControler") as! PDFViewControler
        vc.pdf = doc
        vc.pageNumber = index + 1
        return vc
    }
    
    func indexOfViewController(_ vc:PDFViewControler) -> Int{
        return vc.pageNumber - 1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CGPDFViewController:UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PDFViewControler)
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return self.viewController(at:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PDFViewControler)
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

extension CGPDFViewController:UIPageViewControllerDelegate {
    
}

class PDFViewControler: UIViewController {
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
                    let pageDictionaryCount = CGPDFDictionaryGetCount(pageDictionary)
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

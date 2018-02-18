//
//  PDFKitBasedViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 18..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import PDFKit

class PDFKitBasedPageViewController: UIViewController {
    var pageController:UIPageViewController!
    var doc:PDFDocument? = nil
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pageController.delegate = self
        pageController.dataSource = self

        if let pdfUrl:URL = Bundle.main.url(forResource: "sample_pdf", withExtension: ".pdf") {
            self.doc = PDFDocument(url: pdfUrl)
            self.doc?.delegate = self
            let firstController = self.viewController(at: 0)!
            let controllers = [firstController]
            pageController?.setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
            self.addChildViewController(self.pageController!)
            self.view.addSubview((pageController?.view)!)
            
            self.pageController?.view.frame = self.view.bounds
            pageController?.didMove(toParentViewController: self)
        }
    }
    
    func viewController(at index:Int) -> PDFKitViewController? {
        if doc?.pageCount == 0 || (doc?.pageCount)! < index {
            return nil
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "PDFKitViewController") as! PDFKitViewController
        vc.pdf = doc
        vc.pageNumber = index + 1
        print("viewControllerAt ", vc, vc.pageNumber)
        return vc
    }
    
    func indexOfViewController(_ vc:PDFKitViewController) -> Int {
        return vc.pageNumber - 1
    }
}
extension PDFKitBasedPageViewController: PDFDocumentDelegate {
    // TODO PDFDocumentDelegate
}
extension PDFKitBasedPageViewController: UIPageViewControllerDelegate {
}

extension PDFKitBasedPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PDFKitViewController)
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        return self.viewController(at:index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! PDFKitViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == (doc?.pageCount)! - 1 {
            return nil
        }
        return self.viewController(at:index)
    }
}


class PDFKitViewController:UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editablePdfView: MemesPdfView!
    var pdf:PDFDocument? = nil
    var pageNumber:Int = 1
    override func viewDidLoad() {
        if let pdf = self.pdf {
            print("didload => \(pageNumber)", pdf.pageCount)
            editablePdfView.setPage(page: pdf.page(at: pageNumber)!, width:self.view.frame.size.width)
        }
    }
    
}
extension PDFKitViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         return self.editablePdfView
    }
    
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("didEndZooming ", scale)
    }
}

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
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    var pageController:UIPageViewController!
    var doc:PDFDocument? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    static func randomRect(size:CGSize) -> CGRect {
        let randomSize = CGSize(width:CGFloat(arc4random_uniform(UInt32(size.width))), height:CGFloat(arc4random_uniform(UInt32(size.height))))
        let randomPoint = CGPoint(x:CGFloat(arc4random_uniform(UInt32(size.width))), y:CGFloat(arc4random_uniform(UInt32(size.height))))
        return CGRect(origin:randomPoint, size:randomSize)
    }
    
    let randomAnnotationStrategies = [
        { (bounds:CGRect) -> PDFAnnotation in
            let annotation = PDFAnnotation(bounds: randomRect(size: bounds.size), forType: .circle, withProperties: nil)
            annotation.border = PDFBorder()
            annotation.border?.lineWidth = CGFloat(arc4random_uniform(5))
            annotation.color = .orange
            return annotation
        }
    ]
    
    @IBAction func addRandomAnnotations(_ sender: Any) {
        let vc = pageController.viewControllers![0] as! PDFKitViewController
        let annotation = randomAnnotationStrategies[0](vc.editablePdfView.bounds)
        vc.editablePdfView.page?.addAnnotation(annotation)
        vc.editablePdfView.setNeedsDisplay()
        print("added random Annotation", annotation)
    }
    @IBAction func toggle(_ sender: Any) {
        if pageController.dataSource == nil {
            pageController.dataSource = self
            toggleButton.setTitle("스크롤 락 설정", for: UIControl.State.normal)
        } else {
            pageController.dataSource = nil
            toggleButton.setTitle("스크롤 락 해제", for: UIControl.State.normal)
        }
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
            self.view.insertSubview((pageController?.view)!, belowSubview: self.toggleButton)
            
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
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("didfinish animating", completed)
    }
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
        scrollView.isScrollEnabled  = false
    }
}

extension PDFKitViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

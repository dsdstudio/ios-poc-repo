//
//  NestedScrollViewController.swift
//  RemotePDFViewer
//
//  Created by bohyung kim on 2018. 2. 2..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class NestedScrollViewController: UIViewController {
    @IBOutlet weak var pagingScrollView: UIScrollView!
    var pages = [UIView]()
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.bounds.size.width
        let colorTable = [UIColor.cyan, UIColor.blue, UIColor.darkGray, UIColor.red, UIColor.orange]
        for i in 0...4 {
            let rect = CGRect(origin:CGPoint(x:width * CGFloat(i), y:0), size: view.bounds.size)
            let scrollView = ZoomableScrollView(frame: rect)
            scrollView.backgroundColor = colorTable[i]
            scrollView.isPagingEnabled = false
            scrollView.contentSize = rect.size
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 4
            scrollView.delegate = self
            let containerview = UIView(frame: CGRect(origin:.zero, size:rect.size))
    
            scrollView.addSubview(containerview)
            
            let l = UILabel(frame: CGRect(origin:CGPoint(x:10, y:50), size: CGSize(width: 200, height: 40)))
            l.font = UIFont.systemFont(ofSize: 24)
            l.text = "Page \(i)\n two pinger swipe & panning enabled"
            containerview.addSubview(l)
            pages.append(containerview)
            pagingScrollView.addSubview(scrollView)
            
        }
        
        pagingScrollView.backgroundColor = UIColor.brown
        pagingScrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        self.pagingScrollView.contentSize = CGSize(width: width * CGFloat(5), height: view.bounds.size.height)
    }
}

extension NestedScrollViewController:UIScrollViewDelegate, UIGestureRecognizerDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pages[currentPage]
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("didendzoom", scale)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == pagingScrollView else {
            return
        }
        let width = scrollView.frame.width
        let page = floor((scrollView.contentOffset.x - width / 2) / width) + 1
        currentPage = Int(page)
    }

}

//
//  PoolingScrollViewController.swift
//  ios-poc
//
//  Created by USER on 2018. 6. 22..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift

class PoolingScrollViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    var pagePool:[PageView]?
    var data:[UIColor] = []
    var currentPage:Int = 0
    let bag = DisposeBag()
    override func viewDidLoad() {
        pagePool = []
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
    }
    
    @objc func add(_ b:UIBarButtonItem) {
        let v = newPageView()
        let size = scrollView.contentSize
        v.frame = CGRect(x: size.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        scrollView.addSubview(v)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width + scrollView.frame.width, height: scrollView.frame.height)
        v.removeFromSuperview()
        scrollView.addSubview(v)
        pagePool = Array<PageView>()
        
    }
    
    func newPageView() -> PageView {
        let v = PageView(frame: .zero)
        v.backgroundColor = UIColor.randomColor()
        return v
    }
}

class PageView:UIView {
    
}

protocol PoolingScrollViewDelegate {
}
protocol PoolingScrollViewDataSource {
    func numberOfPage() -> Int
    func pageForRowAt(_ index:Int) -> PageView
}

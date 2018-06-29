//
//  MaterialIndexViewController.swift
//  ios-poc
//
//  Created by USER on 2018. 6. 19..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import MaterialComponents
import MaterialComponents.MaterialMaskedTransition
import RxGesture
import RxSwift
class MaterialIndexViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    let b = { () -> MDCRaisedButton in
        let b = MDCRaisedButton()
        b.frame = CGRect(x: 22, y: 200, width: 100, height: 48)
        b.backgroundColor = .clear
        b.setTitle("눌러봐", for: UIControl.State.normal)
        b.setTitleColor(.orange, for: UIControl.State.normal)
        return b
    }()
    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        b.rx.tapGesture().subscribe(onNext: { [unowned self] g in
            let vc = PopupVC()
            vc.modalPresentationStyle = .custom
            vc.view.backgroundColor = .orange
            vc.transitioningDelegate = self
            
            self.present(vc, animated: true) {
            }
        }).disposed(by: bag)
        view.addSubview(b)
        self.transitioningDelegate = self
    }
}

class PopupVC:UIViewController {
    let button = { () -> UIButton in
        let b = MDCRaisedButton()
        b.frame = CGRect(x: 44, y: 44, width: 100, height: 48)
        b.setTitle("Close", for: UIControl.State.normal)
        b.setTitleColor(.white, for: UIControl.State.normal)
        return b
    }()
    override func viewDidLoad() {
        button.addTarget(self, action: #selector(close), for: UIControl.Event.touchUpInside)
        self.view.addSubview(button)
        print("popupVc DidLoad", self.view.frame)
    }
    @objc func close() {
        self.dismiss(animated: true) {
            
        }
    }
}

extension MaterialIndexViewController:UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MaskPresentAnimator()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MaskDismissAnimator()
    }
}

class MaskDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)
        
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.95)
        
        UIView.animate(withDuration: animationDuration, animations: {
            fromViewController.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
class MaskPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)
        
        toViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            toViewController.view.layer.cornerRadius = 15.0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}


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

class MaterialIndexViewController: UIViewController {

    @IBOutlet weak var textField: MDCTextField!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.placeholder = "Full Name"

        let c = MDCTextInputControllerOutlined(textInput: textField)
        c.helperText = "Name"
        
        let b = MDCRaisedButton()
        b.frame = CGRect(x: 22, y: 200, width: 100, height: 48)
        b.backgroundColor = .clear
        b.setTitle("눌러봐", for: UIControl.State.normal)
        b.setTitleColor(.orange, for: UIControl.State.normal)
        b.addTarget(self, action: #selector(click), for: UIControl.Event.touchUpInside)
        view.addSubview(b)
        self.transitioningDelegate = self
    }
    @objc func click(_ b:MDCButton) {
   
        let transitionDelegate = MDCMaskedTransitionController(sourceView: b)
        let vc = PopupVC()
        vc.view.backgroundColor = .orange
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        
        present(vc, animated: true) {
        }
    }
}

class PopupVC:UIViewController {
    let button = { () -> UIButton in
        let b = UIButton(type: UIButton.ButtonType.roundedRect)
        b.frame = CGRect(x: 44, y: 44, width: 100, height: 40)
//        b.tintColor = .blue
        b.setTitle("Close", for: UIControl.State.normal)
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
        
        containerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.001)
        
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
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}


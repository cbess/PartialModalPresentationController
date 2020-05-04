
//
//  PartialModalPresentationController.swift
//  Soli Deo gloria - perfectGod.com
//
//  Copyright © 2020 Christopher Bess. MIT License.
//

import UIKit

enum PartialModalStyle {
    /// Presents from the bottom of the presenting view up to the specified percent of parent view.
    case fromBottom(percent: CGFloat)
    /// Presents the modal in the center of the presenting view using the specified percentage of the parent view size.
    case toCenter(percent: CGFloat)
}

private let DefaultPartialModalStyle: PartialModalStyle = .fromBottom(percent: 0.7)
private let DefaultMaximizedPartialModalStyle: PartialModalStyle = .fromBottom(percent: 0.95)

class PartialModalPresentationController: UIPresentationController {
    weak var presentationDelegate: PartialModalPresentationDelegate?
    /// The style of the presenting view when unmaximized (normal). Defaults to `fromBottom(0.7)`.
    var modalStyle: PartialModalStyle = DefaultPartialModalStyle
    /// The style of the presenting view when maximized. Defaults to `fromBottom(0.95)`.
    var maximizedModalStyle: PartialModalStyle = DefaultMaximizedPartialModalStyle
    var blurEnabled = false
    var maximized = false
    var blurEffect = UIBlurEffect(style: .dark)
    /// The active modal style, based on the un/maximized state
    private var activeModalStyle: PartialModalStyle {
        return (maximized ? maximizedModalStyle : modalStyle)
    }
    
    private var blurEffectView = UIVisualEffectView()
    private lazy var dimView: UIView = ({
        let cView = self.containerView!
        let dView = UIView(frame: cView.bounds)
        dView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimViewTapped)))
        
        // blur effect
        if self.blurEnabled {
            self.blurEffectView.frame = dView.bounds
            self.blurEffectView.autoresizingMask = dView.autoresizingMask
            dView.addSubview(self.blurEffectView)
        } else {
            dView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        }
        
        return dView
    })()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return frameFromSize(containerView!.bounds.size, style: activeModalStyle)
    }
    
    override func presentationTransitionWillBegin() {
        let cView = containerView!
        cView.addSubview(dimView)
        
        blurEffectView.effect = nil
        if !blurEnabled {
            dimView.alpha = 0
        }
        
        let pView = presentedViewController.view!
        pView.layer.cornerRadius = Theme.General.CornerRadius
        if case PartialModalStyle.fromBottom(_) = activeModalStyle {
            // only round the top corners
            pView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        pView.layer.masksToBounds = true
        pView.frame = cView.bounds
        pView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.addSubview(pView)
        
        if let coord = presentingViewController.transitionCoordinator {
            coord.animate(alongsideTransition: { (context) in
                if self.blurEnabled {
                    self.blurEffectView.effect = self.blurEffect
                } else {
                    self.dimView.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coord = presentingViewController.transitionCoordinator else {
            return
        }
        
        coord.animate(alongsideTransition: { (context) in
            if self.blurEnabled {
                self.blurEffectView.effect = nil
            }
            self.dimView.alpha = 0
            self.presentingViewController.view.transform = .identity
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimView.removeFromSuperview()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.presentedViewController.view.frame = self.frameFromSize(size, style: self.activeModalStyle)
        }, completion: nil)
    }
    
    // MARK: - Misc
    
    @objc func dimViewTapped() {
        presentationDelegate?.partialModalPresentationDimViewTapped(controller: self)
    }
    
    func maximizeViewController() {
        maximized = true
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.presentedViewController.view.frame = self.frameFromSize(self.presentingViewController.view.frame.size, style: self.activeModalStyle)
        }, completion: nil)
    }
    
    func unmaximizeViewController() {
        maximized = false
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.presentedViewController.view.frame = self.frameFromSize(self.presentingViewController.view.frame.size, style: self.activeModalStyle)
        }, completion: nil)
    }
    
    private func frameFromSize(_ origSize: CGSize, style: PartialModalStyle) -> CGRect {
        var frame = CGRect.zero
        
        switch style {
        case let .fromBottom(percent):
            frame.origin.x = 0
            frame.size.width = origSize.width

            let dim = origSize.height * percent // dimensions
            frame.origin.y = origSize.height - dim
            frame.size.height = dim

        case let .toCenter(percent):
            frame.size.width = origSize.width * percent
            frame.size.height = origSize.height * percent

            // place in the center of the dim view
            let dimViewBounds = dimView.bounds
            frame.origin.x = dimViewBounds.midX - frame.midX
            frame.origin.y = dimViewBounds.midY - frame.midY
        }
        
        return frame
    }
}

protocol PartialModalPresentationDelegate: class {
    func partialModalPresentationDimViewTapped(controller: PartialModalPresentationController)
}

protocol PartialModalPresentable {}
extension PartialModalPresentable where Self: UIViewController {
    var partialModalPresentationController: PartialModalPresentationController? {
        return (navigationController?.presentationController as? PartialModalPresentationController) ?? (presentationController as? PartialModalPresentationController)
    }

    func maximize() {
        partialModalPresentationController?.maximizeViewController()
    }
}

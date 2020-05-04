# PartialModalPresentationController

A [presentation controller](https://developer.apple.com/documentation/uikit/uipresentationcontroller) that displays a view controller in a modal overlay style.

[Soli Deo gloria](https://perfectGod.com)

## Usage

```swift
extension SomeOtherViewController {
    func presentPartialModalViewController() {
        someNavigationController.modalPresentationStyle = .custom
        someNavigationController.transitioningDelegate = someNavigationController.topViewController as? MyViewController

        present(someNavigationController, animated: true, completion: nil)
    }
}

extension MyViewController {
    fileprivate var isMaximized: Bool {
        if let controller = navigationController?.presentationController as? PartialModalPresentationController {
            return controller.maximized
        }
        
        return false
    }

    @objc func toggleMaximizeButtonPressed(_ sender: AnyObject) {
        guard let controller = navigationController?.presentationController as? PartialModalPresentationController else {
            return
        }
        
        if isMaximized {
            controller.unmaximizeViewController()
        } else {
            controller.maximizeViewController()
        }
    }
}

extension MyViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let ctrl = PartialModalPresentationController(presentedViewController: presented, presenting: presenting)
        ctrl.presentationDelegate = self
        ctrl.maximized = true
        return ctrl
    }
}

extension MyViewController: PartialModalPresentationDelegate {
    func partialModalPresentationDimViewTapped(controller: PartialModalPresentationController) {
        doneButtonPressed(self)
    }
}
```

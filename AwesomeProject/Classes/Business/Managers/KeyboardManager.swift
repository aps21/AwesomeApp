//
// AwesomeProject
//

import UIKit

typealias KeyboardManagerEventClosure = (KeyboardManagerEvent) -> Void

enum KeyboardManagerEvent {
    case willShow(Data)
    case willHide(Data)
    case willFrameChange(Data)

    struct Frame {
        var begin: CGRect
        var end: CGRect
    }

    struct Data {
        var frame: Frame
        var animationCurve: Int
        var animationDuration: Double
        var isLocal: Bool

        static func null() -> Data {
            let frame = Frame(begin: CGRect.zero, end: CGRect.zero)
            return Data(frame: frame, animationCurve: 0, animationDuration: 0.0, isLocal: false)
        }
    }

    var data: KeyboardManagerEvent.Data {
        switch self {
        case let .willShow(data),
             let .willHide(data),
             let .willFrameChange(data):
            return data
        }
    }
}

protocol KeyboardManagerProtocol: AnyObject {
    var eventClosure: KeyboardManagerEventClosure? { get set }
    func bindToKeyboardNotifications(scrollView: UIScrollView)
    func bindToKeyboardNotifications(superview: UIView, bottomConstraint: NSLayoutConstraint, bottomOffset: CGFloat)
}

final class KeyboardManager {
    let notificationCenter: NotificationCenter
    var eventClosure: KeyboardManagerEventClosure?

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter

        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    private var innerEventClosures: [KeyboardManagerEventClosure] = []

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        invokeClosures(.willShow(extractData(from: notification)))
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        invokeClosures(.willHide(extractData(from: notification)))
    }

    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        invokeClosures(.willFrameChange(extractData(from: notification)))
    }

    private func invokeClosures(_ event: KeyboardManagerEvent) {
        eventClosure?(event)
        innerEventClosures.forEach { $0(event) }
    }

    private func extractData(from notification: Notification) -> KeyboardManagerEvent.Data {
        guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let isLocal = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return KeyboardManagerEvent.Data.null()
        }
        let frame = KeyboardManagerEvent.Frame(begin: beginFrame.cgRectValue, end: endFrame.cgRectValue)
        return KeyboardManagerEvent.Data(
            frame: frame,
            animationCurve: curve.intValue,
            animationDuration: duration.doubleValue,
            isLocal: isLocal.boolValue
        )
    }
}

extension KeyboardManager: KeyboardManagerProtocol {
    func bindToKeyboardNotifications(scrollView: UIScrollView) {
        let initialScrollViewInsets = scrollView.contentInset
        let closure = { [unowned self] event in
            self.handle(by: scrollView, event: event, initialInset: initialScrollViewInsets)
        }
        innerEventClosures += [closure]
    }

    func bindToKeyboardNotifications(superview: UIView, bottomConstraint: NSLayoutConstraint, bottomOffset: CGFloat) {
        let closure: KeyboardManagerEventClosure = {
            switch $0 {
            case let .willShow(data), let .willFrameChange(data):
                bottomConstraint.constant = -data.frame.end.size.height
            case .willHide:
                bottomConstraint.constant = -bottomOffset
            }
            superview.layoutIfNeeded()
        }
        innerEventClosures += [closure]
    }

    private func handle(by scrollView: UIScrollView, event: KeyboardManagerEvent, initialInset: UIEdgeInsets) {
        switch event {
        case let .willShow(data), let .willFrameChange(data):
            UIView.animateKeyframes(
                withDuration: data.animationDuration,
                delay: 0,
                options: UIView.KeyframeAnimationOptions(rawValue: UInt(data.animationCurve)),
                animations: {
                    let inset = initialInset.bottom + data.frame.end.size.height
                    scrollView.contentInset.bottom = inset
                    scrollView.verticalScrollIndicatorInsets.bottom = inset
                }
            )
        case let .willHide(data):
            UIView.animateKeyframes(
                withDuration: data.animationDuration,
                delay: 0,
                options: UIView.KeyframeAnimationOptions(rawValue: UInt(data.animationCurve)),
                animations: {
                    scrollView.contentInset.bottom = initialInset.bottom
                    scrollView.verticalScrollIndicatorInsets.bottom = initialInset.bottom
                }
            )
        }
    }
}

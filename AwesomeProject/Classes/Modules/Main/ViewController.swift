//
// AwesomeProject
//

import UIKit

class ViewController: UIViewController, StateLogger {
    enum VCState: String, ItemProtocol {
        case notInitialized
        case initialized
        case loadView
        case didLoad
        case willAppear
        case didAppear
        case willLayout
        case didLayout
        case willDisappear
        case didDisappear
    }

    let objectType: String = "ViewController"
    var previousState: VCState = .notInitialized

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        logNextState(.initialized, functionName: #function)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        logNextState(.initialized, functionName: #function)
    }

    override func loadView() {
        super.loadView()
        logNextState(.loadView, functionName: #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logNextState(.didLoad, functionName: #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logNextState(.willAppear, functionName: #function)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logNextState(.didAppear, functionName: #function)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logNextState(.willLayout, functionName: #function)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logNextState(.didLayout, functionName: #function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logNextState(.willDisappear, functionName: #function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logNextState(.didDisappear, functionName: #function)
    }
}


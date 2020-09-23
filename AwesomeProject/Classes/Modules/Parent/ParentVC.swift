//
// AwesomeProject
//

import UIKit

class ParentVC: UIViewController {
    private enum VCState: String, ItemProtocol {
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

    private let stateLogger = AppStateLogger<VCState>(instanceType: "ViewController", initialState: .notInitialized)
    private let debugLogger = Logger()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        stateLogger.capture(reason: #function, state: .initialized)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        stateLogger.capture(reason: #function, state: .initialized)
    }

    override func loadView() {
        super.loadView()
        stateLogger.capture(reason: #function, state: .loadView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stateLogger.capture(reason: #function, state: .didLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stateLogger.capture(reason: #function, state: .willAppear)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stateLogger.capture(reason: #function, state: .didAppear)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        stateLogger.capture(reason: #function, state: .willLayout)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stateLogger.capture(reason: #function, state: .didLayout)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stateLogger.capture(reason: #function, state: .willDisappear)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stateLogger.capture(reason: #function, state: .didDisappear)
    }

    func log(message: String) {
        debugLogger.log(message)
    }
}

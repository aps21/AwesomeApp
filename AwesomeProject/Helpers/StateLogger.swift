//
// AwesomeProject
//

import Foundation
import os.log

protocol ItemProtocol: Equatable {
    var rawValue: String { get }
}

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier
    static let stateLogger = OSLog(subsystem: subsystem ?? "", category: "State logger")
}

class AppStateLogger<State: ItemProtocol> {
    let instanceType: String

    private var previousState: State
    private var currentState: State
    private var reason: String = "unknown"

    init(instanceType: String, initialState: State) {
        self.instanceType = instanceType
        self.previousState = initialState
        self.currentState = initialState
    }

    func capture(reason: String, state: State) {
        self.reason = reason
        previousState = self.currentState
        currentState = state
        #if LOGGER
          log()
        #endif
    }

    private func log() {
        if currentState == previousState {
            os_log(
                "%@ was \"%@\": \"%@\"",
                log: .stateLogger,
                type: .debug,
                instanceType,
                previousState.rawValue,
                reason
            )
        } else {
            os_log(
                "%@ moved from \"%@\" to \"%@\" due the reason \"%@\"",
                log: .stateLogger,
                type: .debug,
                instanceType,
                previousState.rawValue,
                currentState.rawValue, reason
            )
        }
    }
}

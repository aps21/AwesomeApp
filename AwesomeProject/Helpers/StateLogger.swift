//
// AwesomeProject
//

import Foundation
import os.log

protocol ItemProtocol: Equatable {
    var rawValue: String { get }
}

protocol StateLogger: AnyObject {
    associatedtype Item: ItemProtocol

    var objectType: String { get }
    var previousState: Item { get set }
    func logNextState(_ nextState: Item, functionName: String)
}

extension StateLogger {
    func logNextState(_ nextState: Item, functionName: String) {
        logState(nextState: nextState, functionName: functionName)
        previousState = nextState
    }

    private func logState(nextState: Item, functionName: String) {
        #if LOGGER
            if nextState == previousState {
                os_log("%@ was %@: %@", type: .debug, objectType, previousState.rawValue, functionName)
            } else {
                os_log("%@ moved from %@ to %@: %@", type: .debug, objectType, previousState.rawValue, nextState.rawValue, functionName)
            }
        #endif
    }
}

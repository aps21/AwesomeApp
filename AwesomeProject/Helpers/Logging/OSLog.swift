//
// AwesomeProject
//

import Foundation
import os.log

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier
    static let stateLogger = OSLog(subsystem: subsystem ?? "", category: "State logger")
    static let debugLogger = OSLog(subsystem: subsystem ?? "", category: "Debug logger")
}

//
// AwesomeProject
//

import Foundation
import os.log

class Logger {
    let logger: OSLog

    init(logger: OSLog = .debugLogger) {
        self.logger = logger
    }

    func log(_ message: String) {
        #if DEBUG
            os_log("%@", log: logger, type: .debug, message)
        #endif
    }
}

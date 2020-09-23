//
// AwesomeProject
//

import Foundation
import os.log

class Logger {
    func log(_ message: String) {
        os_log("%@", log: .debugLogger, type: .debug, message)
    }
}

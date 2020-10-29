//
// AwesomeProject
//

import Foundation
import os.log

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier
    static let debugLogger = OSLog(subsystem: subsystem ?? "", category: "Debug")
    static let coreDataLogger = OSLog(subsystem: subsystem ?? "", category: "CoreData")
}

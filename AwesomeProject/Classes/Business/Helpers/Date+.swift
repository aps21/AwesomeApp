//
// AwesomeProject
//

import Foundation

extension Date {
    func chatDate() -> String {
        if Calendar.current.isDateInToday(self) {
            return DateFormatter.HHmmFormatter.string(from: self)
        }

        return DateFormatter.ddMMMFormatter.string(from: self)
    }
}

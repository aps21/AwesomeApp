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

    func messageDate() -> String {
        if Calendar.current.isDateInToday(self) {
            return DateFormatter.HHmmFormatter.string(from: self)
        }
        if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year) {
            return DateFormatter.ddMMMHHmmFormatter.string(from: self)
        }
        return DateFormatter.ddMMYYFormatter.string(from: self)
    }
}

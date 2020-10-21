//
// AwesomeProject
//

import Foundation

enum L10n {
    enum Alert {
        static let errorTitle = NSLocalizedString("alert.error-title", comment: "")
        static let errorOk = NSLocalizedString("alert.error-ok", comment: "")
        static let errorUnknown = NSLocalizedString("alert.error-unknown", comment: "")
    }

    enum Profile {
        enum AvatarAlert {
            static let title = NSLocalizedString("profile.avatar-alert.title", comment: "")
            static let fromGallery = NSLocalizedString("profile.avatar-alert.from-gallery", comment: "")
            static let fromCamera = NSLocalizedString("profile.avatar-alert.from-camera", comment: "")
            static let delete = NSLocalizedString("profile.avatar-alert.delete", comment: "")
            static let cancel = NSLocalizedString("profile.avatar-alert.cancel", comment: "")
            static let errorDescription = NSLocalizedString("profile.avatar-alert.error-description", comment: "")
            static let errorSettings = NSLocalizedString("profile.avatar-alert.error-settings", comment: "")
        }
    }

    enum Chat {
        static let noMessages = NSLocalizedString("chat.no-messages", comment: "")
        static let onlineHeader = NSLocalizedString("chat.online-header", comment: "")
        static let historyHeader = NSLocalizedString("chat.history-header", comment: "")
    }

    enum Theme {
        static let classic = NSLocalizedString("theme.classic", comment: "")
        static let day = NSLocalizedString("theme.day", comment: "")
        static let night = NSLocalizedString("theme.night", comment: "")
    }
}

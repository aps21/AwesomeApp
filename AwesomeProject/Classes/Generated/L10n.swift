//
// AwesomeProject
//

import Foundation

enum L10n {
    enum Profile {
        enum AvatarAlert {
            static let title = NSLocalizedString("profile.avatar-alert.title", comment: "")
            static let fromGallery = NSLocalizedString("profile.avatar-alert.from-gallery", comment: "")
            static let fromCamera = NSLocalizedString("profile.avatar-alert.from-camera", comment: "")
            static let delete = NSLocalizedString("profile.avatar-alert.delete", comment: "")
            static let cancel = NSLocalizedString("profile.avatar-alert.cancel", comment: "")
            static let errorTitle = NSLocalizedString("profile.avatar-alert.error-title", comment: "")
            static let errorDescription = NSLocalizedString("profile.avatar-alert.error-description", comment: "")
            static let errorSettings = NSLocalizedString("profile.avatar-alert.error-settings", comment: "")
        }
    }

    enum Chat {
        static let noMessages = NSLocalizedString("chat.no-messages", comment: "")
        static let onlineHeader = NSLocalizedString("chat.online-header", comment: "")
        static let historyHeader = NSLocalizedString("chat.history-header", comment: "")
    }
}

//
//  AwesomeProject
//

import UIKit

protocol ThemesPickerDelegate: AnyObject {
    func didSelect(theme: Theme)
}

class ThemesViewController: ParentVC {
    @IBOutlet private var stackView: UIStackView!
    private var themeViews: [ThemeView] = []

    private lazy var initialTheme = themeManager.theme

//    Если у ConversationsListViewController/ThemeManager будет сильная ссылка на ThemesViewController,
//    а у ThemesViewController - на ConversationsListViewController/ThemeManager
//    Чтобы заметить утечку, нужно чтобы ConversationsListViewController тоже создавался несколько раз, а не был главным экраном

    weak var delegate: ThemesPickerDelegate?
    var applyClosure: ((_ theme: Theme) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = themeManager.theme.settingsBGColor
        themeViews = Theme.allCases.compactMap { theme in
            if let themeView = ThemeView.instanceFromNib() {
                themeView.configure(with: theme)
                themeView.setSelected(themeManager.theme == theme)
                themeView.delegate = self
                return themeView
            }
            return nil
        }

        themeViews.forEach { stackView.addArrangedSubview($0) }

        delegate = themeManager
        applyClosure = { [weak self] in self?.themeManager.didSelect(theme: $0) }
    }
}

extension ThemesViewController: ThemesPickerDelegate {
    func didSelect(theme: Theme) {
        if theme != themeManager.theme {
            themeViews.first(where: { $0.model == themeManager.theme })?.setSelected(false)
            view.backgroundColor = theme.settingsBGColor

            // Choose your fighter! 😈
            delegate?.didSelect(theme: theme)
//            applyClosure?(theme)
        }
    }
}

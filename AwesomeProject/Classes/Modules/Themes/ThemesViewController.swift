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

    weak var delegate: ThemesPickerDelegate?

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
    }
}

extension ThemesViewController: ThemesPickerDelegate {
    func didSelect(theme: Theme) {
        if theme != themeManager.theme {
            themeViews.first(where: { $0.model == themeManager.theme })?.setSelected(false)
            view.backgroundColor = theme.settingsBGColor

            delegate?.didSelect(theme: theme)
        }
    }
}

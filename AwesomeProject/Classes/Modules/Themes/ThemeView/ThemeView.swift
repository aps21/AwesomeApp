//
//  AwesomeProject
//

import UIKit

class ThemeView: UIView, ConfigurableView {
    private(set) var model: Theme?

    weak var delegate: ThemesPickerDelegate?

    @IBOutlet private var bubleView: UIView!
    @IBOutlet private var leftImage: UIImageView!
    @IBOutlet private var rightImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        rightImage.image = rightImage.image?.withHorizontallyFlippedOrientation()
        setSelected(false)
    }

    @IBAction private func didSelect() {
        if let model = model {
            setSelected(true)
            delegate?.didSelect(theme: model)
        }
    }

    func configure(with model: Theme) {
        self.model = model
        bubleView.backgroundColor = Color.messageBGColor(theme: model)
        leftImage.tintColor = Color.messagePartnerBGColor(theme: model)
        rightImage.tintColor = Color.messageMyBGColor(theme: model)
        titleLabel.text = model.title
    }

    func setSelected(_ selected: Bool) {
        bubleView.layer.borderColor = (selected ? UIColor(named: "Color/dodgerBlue2") : UIColor(named: "Color/darkGray"))?.cgColor
        bubleView.layer.borderWidth = selected ? 2 : 1
    }
}

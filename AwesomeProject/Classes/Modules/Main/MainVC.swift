//
// AwesomeProject
//

import UIKit

class MainVC: ParentVC {
    private var user = User(
        id: "19837648901",
        firstName: "Marina",
        lastName: "Dudarenko",
        bio: "UX/UI designer, web-designer Moscow, Russia",
        avatarURL: nil
    )

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var saveButton: DefaultButton!

    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        return pickerController
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // Сториборд еще не прогрузился -> кнопка еще не проинициализоровалась
        // Если бы инициализация кнопки происходила в коде,
        // то был бы фрейм, указанный при инициализации, или .zero
        logSaveButtonFrame()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Используются размеры, указанные в сториборде
        logSaveButtonFrame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Вьюха пролейаутилась -> используются размеры девайса
        logSaveButtonFrame()
        updateInfo()
    }

    @IBAction func edit() {
        let alert = UIAlertController(title: L10n.Profile.AvatarAlert.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.fromGallery, style: .default) { [weak self] _ in
            self?.presentImagePicker(type: .photoLibrary)
        })

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.fromCamera, style: .default) { [weak self] _ in
                self?.presentImagePicker(type: .camera)
            })
        }

        if user.avatarURL != nil {
            alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.delete, style: .destructive) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.user.avatarURL = nil
                self.setDefaultImageIfNeeded()
            })
        }


        alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.cancel, style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    @IBAction private func save() {
        saveButton.isEnabled = false
        saveButton.showLoading()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.saveButton.isEnabled = true
            self?.saveButton.hideLoading()
        }
    }

    private func logSaveButtonFrame() {
        log(message: "saveButton.frame = \(saveButton?.frame.debugDescription ?? "no value")")
    }

    private func presentImagePicker(type: UIImagePickerController.SourceType) {
        pickerController.sourceType = type
        present(pickerController, animated: true)
    }

    private func updateInfo() {
        nameLabel.text = user.name
        descriptionLabel.text = user.bio
        setDefaultImageIfNeeded()
    }

    private func setDefaultImageIfNeeded() {
        if user.avatarURL == nil {
            let text = user.firstName.firstSymbol + user.lastName.firstSymbol
            imageView.image = generateImage(with: text, bgColor: UIColor(named: "Color/yellow"), size: imageView.frame.size)
        }
    }

    private func generateImage(with text: String, bgColor: UIColor?, size: CGSize) -> UIImage? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size.height * 105 / 240)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor(named: "Color/charcoal")

        let bgView = UIView(frame: CGRect(origin: .zero, size: size))
        bgView.backgroundColor = bgColor

        label.frame = bgView.frame
        bgView.addSubview(label)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            bgView.layer.render(in: context)
        }
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithText
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension MainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true) { [weak self] in
            self?.imageView.image = info[.editedImage] as? UIImage
            self?.user.avatarURL = (info[.imageURL] as? URL)?.absoluteString
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

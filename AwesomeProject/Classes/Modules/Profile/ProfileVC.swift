//
// AwesomeProject
//

import Photos
import UIKit

class ProfileVC: ParentVC {
    var user: User?

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
        updateInfo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Вьюха пролейаутилась -> используются размеры девайса
        logSaveButtonFrame()
    }

    @IBAction func edit() {
        let alert = UIAlertController(title: L10n.Profile.AvatarAlert.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.fromGallery, style: .default) { [weak self] _ in
            self?.presentImagePicker(type: .photoLibrary)
        })

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.fromCamera, style: .default) { [weak self] _ in
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    self?.presentImagePicker(type: .camera)
                case .denied, .restricted:
                    self?.openAlertDeniedAccessCamera()
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                        if granted {
                            self?.presentImagePicker(type: .camera)
                        } else {
                            self?.openAlertDeniedAccessCamera()
                        }
                    }
                @unknown default:
                    self?.openAlertDeniedAccessCamera()
                }
            })
        }

        if user?.avatarURL != nil {
            alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.delete, style: .destructive) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.user?.avatarURL = nil
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

    @IBAction private func close() {
        dismiss(animated: true)
    }

    private func logSaveButtonFrame() {
        log(message: "saveButton.frame = \(saveButton?.frame.debugDescription ?? "no value")")
    }

    private func presentImagePicker(type: UIImagePickerController.SourceType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.pickerController.sourceType = type
            self.present(self.pickerController, animated: true)
        }
    }

    private func openAlertDeniedAccessCamera() {
        let alerVC = UIAlertController(
            title: L10n.Profile.AvatarAlert.errorTitle,
            message: L10n.Profile.AvatarAlert.errorDescription,
            preferredStyle: .alert
        )
        alerVC.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.cancel, style: .default, handler: nil))
        alerVC.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.errorSettings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        present(alerVC, animated: true)
    }

    private func updateInfo() {
        nameLabel.text = user?.name
        descriptionLabel.text = user?.bio
        setDefaultImageIfNeeded()
    }

    private func setDefaultImageIfNeeded() {
        if let user = user, user.avatarURL == nil {
            let text = user.initials
            imageView.image = AvatarHelper.generateImage(with: text, bgColor: UIColor(named: "Color/yellow"), size: imageView.frame.size)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true) { [weak self] in
            self?.imageView.image = info[.editedImage] as? UIImage
            self?.user?.avatarURL = "someUrl"
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

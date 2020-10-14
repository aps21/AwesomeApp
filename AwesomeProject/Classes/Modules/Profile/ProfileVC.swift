//
// AwesomeProject
//

import Photos
import UIKit

class ProfileVC: ParentVC {
    let gcdManager = GCDDataManager()
    let operationManager = OperationDataManager()
    lazy var keyboardManager: KeyboardManagerProtocol = KeyboardManager(notificationCenter: notificationCenter)

    private var currentAvatar: UIImage?
    private var user: User? {
        didSet {
            currentAvatar = user?.image
            updateInfo()
        }
    }

    private var isEditingMode = false {
        didSet {
            contentViews.forEach { $0.isHidden = isEditingMode }
            editingViews.forEach { $0.isHidden = !isEditingMode }

            if isEditingMode {
                editButton.title = "Cancel"
            } else {
                editButton.title = "Edit profile"
            }
        }
    }

    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        return pickerController
    }()

    @IBOutlet private var contentStack: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var saveGCDButton: DefaultButton!
    @IBOutlet private var saveOperationButton: DefaultButton!
    @IBOutlet private var editButton: UIBarButtonItem!
    // TODO: Remove later
    @IBOutlet private var loader: UIActivityIndicatorView!

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var descriptionTextView: UITextView!

    @IBOutlet private var contentViews: [UIView]!
    @IBOutlet private var editingViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        loader.startAnimating()
        let manager: UserManager = Bool.random() ? gcdManager : operationManager
        manager.savedUser { [weak self] savedUser in
            self?.loader.stopAnimating()
            self?.contentStack.isHidden = false
            self?.user = savedUser
        }

        descriptionTextView.layer.cornerRadius = 7
        descriptionTextView.layer.borderColor = Color.gray?.cgColor
        descriptionTextView.layer.borderWidth = 1

        keyboardManager.bindToKeyboardNotifications(scrollView: scrollView)
        addTapToHideKeyboardGesture()

    }

    @IBAction func edit() {
        isEditingMode.toggle()
    }

    @IBAction func editAvatar() {
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

        if currentAvatar != nil {
            alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.delete, style: .destructive) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.currentAvatar = nil
                self.setDefaultImageIfNeeded()
                self.updateSavingButtons(didChangeImage: true)
            })
        }


        alert.addAction(UIAlertAction(title: L10n.Profile.AvatarAlert.cancel, style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    @IBAction private func save(button: DefaultButton) {
        saveGCDButton.isEnabled = false
        saveOperationButton.isEnabled = false

        button.showLoading()
        loader.startAnimating()

        let manager: UserManager = button == saveGCDButton ? gcdManager : operationManager
        manager.save(name: nameTextField.text, bio: descriptionTextView.text, avatar: currentAvatar) { [weak self] success in
            if success {
                self?.view.endEditing(true)
                self?.openSuccessAlert()
                let currentUserInfo = User(
                    name: self?.nameTextField.text,
                    bio: self?.descriptionTextView.text,
                    imageData: self?.currentAvatar?.pngData()
                )
                self?.user = currentUserInfo
                self?.notificationCenter.post(name: .userUpdate, object: currentUserInfo)
                self?.isEditingMode = false
                self?.updateSavingButtons()
            } else {
                self?.openFailureAlert(button)
            }
            self?.loader.stopAnimating()
            button.hideLoading()
        }
    }

    @IBAction private func close() {
        dismiss(animated: true)
    }

    override func updateColors() {
        super.updateColors()
        view.backgroundColor = Color.white
        nameLabel.textColor = Color.black
        descriptionLabel.textColor = Color.black
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

    // TODO: L10n
    private func openSuccessAlert() {
        let alerVC = UIAlertController(
            title: "Данные сохранены",
            message: nil,
            preferredStyle: .alert
        )
        alerVC.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alerVC, animated: true)
    }

    private func openFailureAlert(_ saveButton: DefaultButton) {
        let alerVC = UIAlertController(
            title: "Ошибка",
            message: "Не удалось сохранить данные",
            preferredStyle: .alert
        )
        alerVC.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        alerVC.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in self?.save(button: saveButton) }))
        present(alerVC, animated: true)
    }

    private func updateInfo() {
        nameLabel.text = user?.name
        descriptionLabel.text = user?.bio
        nameTextField.text = user?.name
        descriptionTextView.text = user?.bio
        if let avatar = user?.image {
            imageView.image = avatar
        } else {
            setDefaultImageIfNeeded()
        }
    }

    private func updateSavingButtons(didChangeImage: Bool = false) {
        let didChangeData = didChangeImage || nameTextField.text != (user?.name ?? "") || descriptionTextView.text != (user?.bio ?? "")
        saveGCDButton.isEnabled = didChangeData
        saveOperationButton.isEnabled = didChangeData
    }

    private func setDefaultImageIfNeeded() {
        if user?.imageData == nil {
            imageView.image = gcdManager.avatarImage(userData: user, height: imageView.frame.height)
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
            let image = info[.editedImage] as? UIImage
            self?.imageView.image = image
            self?.currentAvatar = image
            self?.updateSavingButtons(didChangeImage: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_: UITextField) {
        updateSavingButtons()
    }
}

extension ProfileVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToVisibleRect(with: textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        updateSavingButtons()
    }

    private func scrollToVisibleRect(with textView: UITextView) {
        guard let frame = textView.superview?.convert(textView.frame, to: scrollView) else {
            return
        }
        scrollView.scrollRectToVisible(frame, animated: true)
    }
}

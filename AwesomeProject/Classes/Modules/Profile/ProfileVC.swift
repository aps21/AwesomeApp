//
// AwesomeProject
//

import Photos
import UIKit

class ProfileVC: ParentVC {
    let gcdManager: UserManager = GCDDataManager()
    let operationManager: UserManager = OperationDataManager()
    lazy var keyboardManager: KeyboardManagerProtocol = KeyboardManager(notificationCenter: notificationCenter)

    private let editButtonAnimationKey = "Animation.Profile.EditButton"

    private var currentAvatar: UIImage?
    private var user: User? {
        didSet {
            currentAvatar = user?.image
            updateInfo()
        }
    }

    private var isEditingMode = false {
        didSet {
            toggleButtonAnimation()

            contentViews.forEach { $0.isHidden = isEditingMode }
            editingViews.forEach { $0.isHidden = !isEditingMode }

            if isEditingMode {
                editButton.setTitle("Cancel", for: .normal)
            } else {
                editButton.setTitle("Edit profile", for: .normal)
            }
        }
    }

    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        return pickerController
    }()

    private lazy var editButtonAnimation: CAAnimationGroup = {
        let angle: CGFloat = 18 * .pi / 180

        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotate.values = [0, -angle, angle, 0]
        rotate.keyTimes = [0, 0.3, 0.75, 1]
        rotate.isAdditive = true

        let moveY = CAKeyframeAnimation(keyPath: "transform.translation.y")
        moveY.values = [0, -5, -5, 5, 0]
        moveY.keyTimes = [0.25, 0.3, 0.5, 0.75, 1]
        moveY.isAdditive = true

        let moveX = CAKeyframeAnimation(keyPath: "transform.translation.x")
        moveX.values = moveY.values
        moveX.keyTimes = moveY.keyTimes
        moveX.isAdditive = true

        let group = CAAnimationGroup()
        group.duration = 0.3
        group.repeatCount = .infinity
        group.animations = [rotate, moveY, moveX]
        return group
    }()

    @IBOutlet private var contentStack: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var saveGCDButton: DefaultButton!
    @IBOutlet private var saveOperationButton: DefaultButton!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var loader: UIActivityIndicatorView!

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var descriptionTextView: UITextView!

    @IBOutlet private var contentViews: [UIView]!
    @IBOutlet private var editingViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        editButton.accessibilityIdentifier = "editButton"
        loader.startAnimating()
        let manager: UserManager = Bool.random() ? gcdManager : operationManager
        manager.savedUser { [weak self] savedUser in
            self?.loader.stopAnimating()
            self?.contentStack.isHidden = false
            self?.user = savedUser
        }

        [nameTextField, descriptionTextView].forEach { (view: UIView) in
            view.layer.cornerRadius = 7
            view.layer.borderColor = Color.gray?.cgColor
            view.layer.borderWidth = 1
        }

        keyboardManager.bindToKeyboardNotifications(scrollView: scrollView)
        addTapToHideKeyboardGesture()

        editButton.layer.borderWidth = 2
        editButton.layer.borderColor = UIColor.blue.cgColor
        editButton.layer.cornerRadius = 5
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

        alert.addAction(UIAlertAction(title: "Загрузить", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "images", sender: nil)
        })

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

        let manager = button == saveGCDButton ? gcdManager : operationManager
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

        nameTextField.backgroundColor = Color.white
        nameTextField.textColor = Color.black

        descriptionTextView.backgroundColor = Color.white
        descriptionTextView.textColor = Color.black
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let destination = segue.destination as? ProfileImagesVC {
            destination.delegate = self
        }
    }

    private func toggleButtonAnimation() {
        if isEditingMode {
            editButton.layer.add(editButtonAnimation, forKey: editButtonAnimationKey)
        } else {
            guard let currentAnimation = editButton.layer.animation(forKey: editButtonAnimationKey)?.copy() as? CAAnimationGroup else {
                return
            }

            CATransaction.setCompletionBlock({
                self.editButton.layer.removeAllAnimations()
            })

            CATransaction.begin()
            currentAnimation.fillMode = .backwards
            CATransaction.commit()
        }
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
            title: L10n.Alert.errorTitle,
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
            guard let image = info[.editedImage] as? UIImage else {
                return
            }
            self?.didSelect(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldDidChange(_: UITextField) {
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

// MARK: - ProfileImagesDelegate

extension ProfileVC: ProfileImagesDelegate {
    func didSelect(image: UIImage) {
        imageView.image = image
        currentAvatar = image
        updateSavingButtons(didChangeImage: true)
    }
}

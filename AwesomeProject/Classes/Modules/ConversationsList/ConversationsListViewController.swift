//
// AwesomeProject
//

import Firebase
import UIKit

class ConversationsListViewController: ParentVC {
    private enum Constants {
        static let cellReuseId = String(describing: ConversationCell.self)
        static let profileSegue = "profile"
        static let conversationSegue = "conversation"
        static let avatarHeight: CGFloat = 40
    }

    private let coreDataStack = CoreDataStack.shared
    private let userManager = GCDDataManager()

    private var observationUser: NSObjectProtocol?
    private var isInitial = true
    private var user: User?

    private lazy var database = Firestore.firestore()
    private lazy var channelsReference = database.collection("channels")

    private lazy var data: [Channel] = []
    private lazy var avatarBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: avatarButton)
    }()

    private lazy var avatarButton: UIButton = {
        let button = SimpleImageButton(frame: CGRect(x: 0, y: 0, width: Constants.avatarHeight, height: Constants.avatarHeight))
        button.layer.cornerRadius = Constants.avatarHeight / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        return button
    }()

    @IBOutlet private var tableView: UITableView!

    deinit {
        if let observer = observationUser {
            notificationCenter.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        userManager.savedUser { [weak self] user in
            self?.didUpdateUser(user: user)
        }

        observationUser = notificationCenter.addObserver(forName: .userUpdate, object: nil, queue: .main) { [weak self] notification in
            let user = notification.object as? User
            self?.didUpdateUser(user: user)
        }

        tableView.register(UINib(nibName: Constants.cellReuseId, bundle: nil), forCellReuseIdentifier: Constants.cellReuseId)

        loadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let destination = segue.destination as? ConversationViewController,
            let channel = sender as? Channel {
            destination.channel = channel
            destination.user = user
        }
    }

    override func updateColors() {
        super.updateColors()
        tableView.backgroundColor = Color.white
        tableView.reloadData()
    }

    @IBAction private func addChannel() {
        let alertVC = UIAlertController(title: "Создать новый", message: "Введите название канала", preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "Название"
        }
        alertVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            guard let self = self, let name = alertVC.textFields?.first?.text, !name.isEmpty else {
                return
            }
            self.create(name: name)
        })
        present(alertVC, animated: true)
    }

    @objc
    private func openProfile() {
        performSegue(withIdentifier: Constants.profileSegue, sender: nil)
    }

    private func create(name: String) {
        channelsReference.addDocument(data: ["name": name])
    }

    private func loadData() {
        channelsReference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot else {
                self.show(error: error?.localizedDescription)
                return
            }

            self.coreDataStack.performSave { context in
                snapshot.documentChanges.forEach { diff in
                    let document = diff.document
                    let id = document.documentID

                    let index = self.data.firstIndex(where: { $0.identifier == id })
                    switch diff.type {
                    case .added, .modified:
                        _ = DBChannel(id: id, dictionary: document.data(), in: context)
                        let channel = Channel(id: id, dictionary: document.data())
                        if let index = index {
                            self.data.remove(at: index)
                            if let channel = channel {
                                self.data.insert(channel, at: 0)
                            }
                        } else if let channel = channel {
                            self.data.insert(channel, at: 0)
                        }
                    case .removed:
                        if let index = index {
                            self.data.remove(at: index)
                        }
                    }
                }

                if self.isInitial {
                    self.isInitial = false
                    self.data = self.data.sorted(by: { channel1, channel2 in
                        switch (channel1.lastActivity, channel2.lastActivity) {
                        case let (.some(activity1), .some(activity2)):
                            return activity1 >= activity2
                        case (.none, _):
                            return false
                        case (_, .none):
                            return true
                        }
                    })
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func didUpdateUser(user: User?) {
        self.user = user
        let image = userManager.avatarImage(userData: user, height: Constants.avatarHeight)
        avatarButton.setImage(image, for: .normal)
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }

    private func show(error: String?) {
        let alertVC = UIAlertController(title: L10n.Alert.errorTitle, message: error ?? L10n.Alert.errorUnknown, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: L10n.Alert.errorOk, style: .default, handler: nil))
        present(alertVC, animated: true)
    }
}

// MARK: - UITableView

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }

        if data.count > indexPath.row {
            let model = ConversationCellModel(channel: data[indexPath.row])
            cell.configure(with: model)
            if data.count - 1 == indexPath.row {
                cell.hideDivider()
            }
        }

        return cell
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: Constants.conversationSegue, sender: data[indexPath.row])
    }
}

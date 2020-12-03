//
// AwesomeProject
//

import CoreData
import Firebase
import UIKit

class ConversationsListViewController: ParentVC {
    private enum Constants {
        static let cellReuseId = String(describing: ConversationCell.self)
        static let profileSegue = "profile"
        static let conversationSegue = "conversation"
        static let avatarHeight: CGFloat = 40
    }

    private let userManager: UserManager = GCDDataManager()

    private var observationUser: NSObjectProtocol?
    private var user: User?

    private lazy var service: ChannelsServiceProtocol = ChannelsService(path: "channels")
    private lazy var dataSource: ChannelDataSource =
        ConversationsFetchedResultsObject(parentId: nil, tableView: tableView, delegate: self)

    private lazy var avatarBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: avatarButton)
    }()

    private lazy var avatarButton: UIButton = {
        let button = SimpleImageButton(frame: CGRect(x: 0, y: 0, width: Constants.avatarHeight, height: Constants.avatarHeight))
        button.accessibilityIdentifier = "profile"
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

        tableView.reloadData()
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
        service.create(name: name)
    }

    private func loadData() {
        service.loadData { [weak self] error in
            if let error = error {
                self?.show(error: error.localizedDescription)
            }
        }
    }

    private func didUpdateUser(user: User?) {
        self.user = user
        let image = userManager.avatarImage(userData: user, height: Constants.avatarHeight)
        avatarButton.setImage(image, for: .normal)
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }
}

// MARK: - UITableView

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.total
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }

        let channel = dataSource.object(at: indexPath)
        let model = ConversationCellModel(channel: channel)
        cell.configure(with: model)
        return cell
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let dbChannel = dataSource.object(at: indexPath)
        let channel = Channel(dbChannel: dbChannel)
        performSegue(withIdentifier: Constants.conversationSegue, sender: channel)
    }

    func tableView(
        _: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = deleteContextualAction(for: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func deleteContextualAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            let channelId = self.dataSource.object(at: indexPath).identifier
            self.service.delete(id: channelId) { [weak self] error in
                if let error = error {
                    self?.show(error: error.localizedDescription)
                    completion(false)
                } else {
                    completion(true)
                }
            }
            completion(true)
        }
        action.image = UIImage(named: "Conversations/delete")
        action.backgroundColor = Color.lightYellowColor
        return action
    }
}

// MARK: - FinishProtocol

extension ConversationsListViewController: FinishProtocol {
    func didFinish() {}
}

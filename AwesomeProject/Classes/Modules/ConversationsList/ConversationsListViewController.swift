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

    private let coreDataStack = CoreDataStack.shared
    private let userManager = GCDDataManager()

    private var observationUser: NSObjectProtocol?
    private var user: User?

    private lazy var database = Firestore.firestore()
    private lazy var channelsReference = database.collection("channels")

    private lazy var fetchResultController: NSFetchedResultsController<DBChannel> = {
        let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            self.show(error: error.localizedDescription)
        }
        return controller
    }()

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

                    switch diff.type {
                    case .added, .modified:
                        _ = DBChannel(id: id, dictionary: document.data(), in: context)
                    case .removed:
                        if let channel = (try? context.fetch(DBChannel.fetchRequest(channelId: id)))?.first {
                            context.delete(channel)
                        }
                    }
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
        fetchResultController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }

        let channel = fetchResultController.object(at: indexPath)
        let model = ConversationCellModel(channel: channel)
        cell.configure(with: model)
        return cell
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let dbChannel = fetchResultController.object(at: indexPath)
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
            let channelId = self.fetchResultController.object(at: indexPath).identifier
            self.channelsReference.document(channelId).delete { [weak self] error in
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

// MARK: - NSFetchedResultsControllerDelegate

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard anObject is DBChannel else {
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath else {
                return
            }
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
                return
            }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        default:
            return
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

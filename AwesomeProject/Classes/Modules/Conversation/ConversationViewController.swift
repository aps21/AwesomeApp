//
// AwesomeProject
//

import CoreData
import Firebase
import UIKit

class ConversationViewController: ParentVC {
    private enum Constants {
        static let cellReuseId = String(describing: MessageCell.self)
    }

    private let coreDataStack = CoreDataStack.shared
    private var isInitial = true

    private lazy var keyboardManager: KeyboardManagerProtocol = KeyboardManager(notificationCenter: notificationCenter)
    private lazy var database = Firestore.firestore()
    private lazy var messagesReference = database.collection("channels/\(channel.identifier)/messages")

    private lazy var fetchResultController: NSFetchedResultsController<DBMessage> = {
        let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest(channelId: channel.identifier)
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

    private lazy var bottomInset: CGFloat = {
        bottomView.layoutIfNeeded()
        return bottomView.frame.height
    }()

    var channel: Channel!
    var user: User?

    private let prototypeCell = MessageCell.instanceFromNib()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var bottomView: UIView!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var emptyView: UIView!
    @IBOutlet private var loaderView: UIActivityIndicatorView!
    @IBOutlet private var sendButton: UIButton!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: Constants.cellReuseId, bundle: nil), forCellReuseIdentifier: Constants.cellReuseId)
        navigationItem.titleView = ConversationTitle(title: channel.name, color: channel.color)

        textView.layer.cornerRadius = 7
        textView.layer.borderColor = Color.gray?.cgColor
        textView.layer.borderWidth = 1

        addTapToHideKeyboardGesture()
        keyboardManager.bindToKeyboardNotifications(superview: view, bottomConstraint: bottomConstraint, bottomOffset: 0)
        keyboardManager.eventClosure = { [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case let .willShow(data):
                self.bottomInset = self.bottomView.frame.height + data.frame.end.size.height
                self.tableView.contentInset.bottom = self.bottomInset
                let newOffset = self.tableView.contentOffset.y + data.frame.end.size.height - self.view.safeAreaInsets.bottom
                self.tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: true)
            case .willHide:
                self.bottomInset = self.bottomView.frame.height + self.view.safeAreaInsets.bottom
                let newInset = self.bottomInset
                let newOffset = self.tableView.contentOffset.y - self.tableView.contentInset.bottom + newInset
                self.tableView.contentInset.bottom = newInset
                self.tableView.setContentOffset(CGPoint(x: 0, y: max(-self.tableView.contentInset.top, newOffset)), animated: true)

                let yOffset = self.tableView.contentSize.height - self.view.frame.height + self.bottomInset
                self.tableView.contentInset.top = max(self.view.safeAreaInsets.top, -yOffset)
                self.tableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
            case .willFrameChange:
                break
            }
        }

        reloadData(isPrereload: true)
        loadData()
    }

    override func updateColors() {
        super.updateColors()
        view.backgroundColor = Color.white
        loaderView.color = Color.black
        tableView.reloadData()

        bottomView.backgroundColor = Color.lightGray
        textView.backgroundColor = Color.white
        textView.textColor = Color.black
    }

    @IBAction private func send() {
        guard let user = user, user.senderId != nil, !textView.text.isEmpty else {
            show(error: nil)
            return
        }

        isInitial = true
        sendButton.isEnabled = false
        messagesReference.addDocument(data: Message.payload(message: textView.text, user: user)) { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.show(error: error.localizedDescription)
            } else {
                self.textView.text = ""
            }
        }
    }

    private func reloadData(isPrereload: Bool = false) {
        // TODO: Refactor scroll to bottom
        let epsilon: CGFloat = 10
        if !isInitial,
            tableView.contentSize.height - tableView.contentOffset.y + tableView.contentInset.bottom <= view.frame.height + epsilon {
            isInitial = true
        }

        if isInitial {
            tableView.isHidden = false
            if !isPrereload {
                isInitial = false
            }
            let yOffset = tableView.contentSize.height - view.frame.height + bottomInset
            tableView.contentInset.top = max(view.safeAreaInsets.top, -yOffset)
            if tableView.contentInset.bottom < bottomInset {
                tableView.contentInset.bottom = bottomInset
                tableView.scrollIndicatorInsets.bottom = bottomInset
            }
            tableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
            loaderView.stopAnimating()
            emptyView.isHidden = !((fetchResultController.fetchedObjects ?? []).isEmpty && !isPrereload)
        }
    }

    private func loadData() {
        messagesReference.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let snapshot = snapshot else {
                return
            }

            self.coreDataStack.performSave { [weak self] context in
                guard let self = self else {
                    return
                }

                var dbMessages: [DBMessage] = []

                snapshot.documentChanges.forEach { diff in
                    let document = diff.document
                    let id = document.documentID

                    switch diff.type {
                    case .added, .modified:
                        if let dbMessage = DBMessage(id: id, dictionary: document.data(), in: context) {
                            dbMessages.append(dbMessage)
                        }
                    case .removed:
                        if let message = (try? context.fetch(DBMessage.fetchRequest(messageId: id)))?.first {
                            context.delete(message)
                        }
                    }
                }
                if !dbMessages.isEmpty {
                    let channel = (try? context.fetch(DBChannel.fetchRequest(channelId: self.channel.identifier)))?.first
                    channel?.addToMessages(NSSet(array: dbMessages))
                }
            }
        }
    }

    private func show(error: String?) {
        let alertVC = UIAlertController(title: L10n.Alert.errorTitle, message: error ?? L10n.Alert.errorUnknown, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: L10n.Alert.errorOk, style: .default, handler: nil))
        present(alertVC, animated: true)
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchResultController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }

        configure(cell: cell, indexPath: indexPath)
        return cell
    }

    private func configure(cell: MessageCell, indexPath: IndexPath) {
        let message = fetchResultController.object(at: indexPath)
        cell.configure(with: MessageCellModel(message: Message(dbMessage: message), isMine: message.senderId == user?.senderId))
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let prototypeCell = prototypeCell else {
            return tableView.estimatedRowHeight
        }

        configure(cell: prototypeCell, indexPath: indexPath)
        return prototypeCell.contentView.systemLayoutSizeFitting(
            CGSize(width: view.frame.width, height: UIView.noIntrinsicMetric),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height
    }

    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView(table, estimatedHeightForRowAt: indexPath)
    }
}

extension ConversationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ConversationViewController: NSFetchedResultsControllerDelegate {
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
        guard anObject is DBMessage else {
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRows(at: [newIndexPath], with: .none)
        case .delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRows(at: [indexPath], with: .none)
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
        reloadData()
    }
}

//
// AwesomeProject
//

import UIKit

class ConversationsListViewController: ParentVC {
    private enum Constants {
        static let cellReuseId = String(describing: ConversationCell.self)
        static let headerReuseId = String(describing: ConversationsHeader.self)
        static let profileSegue = "profile"
        static let conversationSegue = "conversation"
    }

    // TODO: Temp data
    private var user = User(
        id: "19837648901",
        firstName: "Marina",
        lastName: "Dudarenko",
        bio: "UX/UI designer, web-designer Moscow, Russia",
        avatarURL: nil
    )

    private lazy var data: [Int: [ConversationCellModel]] = [
        0: (0 ... 20).map { _ in randomCellVM(isOnline: true) }.sorted(by: { $0.date > $1.date }),
        1: (0 ... 20).map { _ in randomCellVM(isOnline: false) }.sorted(by: { $0.date > $1.date }),
    ]

    private lazy var avatarBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: avatarButton)
    }()

    private lazy var avatarButton: UIButton = {
        let height: CGFloat = 40
        let image = AvatarHelper.generateImage(
            with: user.initials,
            bgColor: UIColor(named: "Color/yellow"),
            size: CGSize(width: height, height: height)
        )
        let button = SimpleImageButton()
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = height / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        return button
    }()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = avatarBarButtonItem

        tableView.contentInset.bottom = 50
        tableView.register(UINib(nibName: Constants.cellReuseId, bundle: nil), forCellReuseIdentifier: Constants.cellReuseId)
        tableView.register(
            UINib(nibName: Constants.headerReuseId, bundle: nil),
            forHeaderFooterViewReuseIdentifier: Constants.headerReuseId
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let destination = (segue.destination as? UINavigationController)?.topViewController as? ProfileVC {
            destination.user = user
        } else if let destination = segue.destination as? ConversationViewController {
            destination.conversation = sender as? ConversationCellModel
        }
    }

    @objc
    private func openProfile() {
        performSegue(withIdentifier: Constants.profileSegue, sender: nil)
    }

    override func updateColors() {
        super.updateColors()
        view.backgroundColor = Color.white
        tableView.reloadData()
    }

    private func randomCellVM(isOnline: Bool) -> ConversationCellModel {
        let model = ConversationCellModel(
            name: ["Ronald Robertson", "Johnny Watson", "Martha Craig", "Arthur Bell", "Jane Warren", "Morris Henry"].randomElement() ?? "",
            message: [
                    "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                    "Voluptate irure",
                    ""
                ].randomElement() ?? "",
            date: Date(timeIntervalSinceNow: TimeInterval.random(in: -1000000...0)),
            isOnline: isOnline,
            hasUnreadMessages: .random()
        )
        return model
    }
}

// MARK: - UITableView

extension ConversationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        [data[0]?.isEmpty, data[1]?.isEmpty].compactMap { $0 == false ? [] : nil }.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data[section]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }

        if let data = data[indexPath.section], data.count > indexPath.row {
            cell.configure(with: data[indexPath.row])
            if data.count - 1 == indexPath.row {
                cell.hideDivider()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.headerReuseId) as? ConversationsHeader
        header?.configure(isOnline: section == 0)
        return header
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: Constants.conversationSegue, sender: data[indexPath.section]?[indexPath.row])
    }
}

//
// AwesomeProject
//

import UIKit

class ConversationViewController: ParentVC {
    private enum Constants {
        static let cellReuseId = String(describing: MessageCell.self)
    }

    private var messages: [MessageCellModel] = []

    var conversation: ConversationCellModel? {
        didSet {
            if conversation?.message.isEmpty ?? true {
                messages = []
            } else {
                var randomMessages = (0 ... .random(in: 0 ... 20)).map { _ in randomCellVM() }
                randomMessages.append(MessageCellModel(text: conversation?.message ?? "", isMine: .random()))
                messages = randomMessages
            }
        }
    }

    private let prototypeCell = MessageCell.instanceFromNib()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyView: UIView!
    @IBOutlet private var loaderView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: Constants.cellReuseId, bundle: nil), forCellReuseIdentifier: Constants.cellReuseId)
        navigationItem.titleView = ConversationTitle(title: conversation?.name ?? "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadData()
    }

    private func randomCellVM() -> MessageCellModel {
        MessageCellModel(
            text: [
                "An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum. An suas viderer pro. Vis cu magna altera, ex his vivendo atomorum.",
                "Voluptate irure",
                "Voluptate irure. Vis cu magna"
            ].randomElement() ?? "",
            isMine: .random()
        )
    }

    private func reloadData() {
        tableView.layoutIfNeeded()

        let yOffset = tableView.contentSize.height - view.frame.height + view.safeAreaInsets.bottom
        tableView.contentInset.top = max(1, -yOffset)
        tableView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
        tableView.isHidden = false
        loaderView.stopAnimating()
        emptyView.isHidden = !messages.isEmpty
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }

        cell.configure(with: messages[indexPath.row])

        return cell
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let prototypeCell = prototypeCell else {
            return tableView.estimatedRowHeight
        }

        prototypeCell.configure(with: messages[indexPath.row])
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

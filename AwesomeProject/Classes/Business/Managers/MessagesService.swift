//
//  AwesomeProject
//

import Firebase
import Foundation

protocol MessagesServiceProtocol {
    func loadData(channelId: String, completion: @escaping (_ error: Error?) -> Void)
    func send(message: String, user: User, completion: @escaping (_ error: Error?) -> Void)
}

class MessagesService: FirebaseStorage, MessagesServiceProtocol {
    private let storage: MessageDataStorage = MessageStorage()

    func loadData(channelId: String, completion: @escaping (_ error: Error?) -> Void) {
        collectionReference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot else {
                completion(error)
                return
            }

            self.storage.save(channelId: channelId, messages: snapshot.documentChanges.map { diff in
                let type: DataItem.DiffType
                switch diff.type {
                case .added:
                    type = .added
                case .modified:
                    type = .modified
                case .removed:
                    type = .removed
                }
                let document = diff.document
                return DataItem(id: document.documentID, dictionary: document.data(), type: type)
            })

            completion(error)
        }
    }

    func send(message: String, user: User, completion: @escaping (_ error: Error?) -> Void) {
        collectionReference.addDocument(data: Message.payload(message: message, user: user)) { completion($0) }
    }
}

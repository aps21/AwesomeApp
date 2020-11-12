//
//  AwesomeProject
//

import Firebase
import Foundation

protocol ChannelsServiceProtocol {
    func loadData(completion: @escaping (_ error: Error?) -> Void)
    func create(name: String)
    func delete(id: String, completion: @escaping (_ error: Error?) -> Void)
}

class ChannelsService: FirebaseStorage, ChannelsServiceProtocol {
    private let storage: ChannelDataStorage = ChannelStorage()

    func loadData(completion: @escaping (_ error: Error?) -> Void) {
        collectionReference.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot else {
                completion(error)
                return
            }

            self.storage.save(channels: snapshot.documentChanges.map { diff in
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

    func create(name: String) {
        collectionReference.addDocument(data: ["name": name])
    }

    func delete(id: String, completion: @escaping (_ error: Error?) -> Void) {
        collectionReference.document(id).delete { completion($0) }
    }
}

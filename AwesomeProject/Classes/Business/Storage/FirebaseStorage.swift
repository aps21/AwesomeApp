//
//  AwesomeProject
//

import Firebase

class FirebaseStorage {
    private let path: String
    private lazy var database = Firestore.firestore()
    private(set) lazy var collectionReference = database.collection(path)

    init(path: String) {
        self.path = path
    }
}

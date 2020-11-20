//
//  AwesomeProject
//

import UIKit

class RootAssembly {
    lazy var serviceAssembly: IServicesAssembly = ServicesAssembly(coreAssembly: self.coreAssembly)
    private lazy var coreAssembly: ICoreAssembly = CoreAssembly()
}

protocol ProfileImagesDelegate: AnyObject {
    func didSelect(image: UIImage)
}

class ProfileImagesVC: ParentVC {
    private enum Constants {
        static let reuseId = String(describing: ProfileImageCell.self)
    }

    @IBOutlet private var loader: UIActivityIndicatorView!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewLayout: UICollectionViewFlowLayout!

    let service: IImagesService = RootAssembly().serviceAssembly.imagesService

    weak var delegate: ProfileImagesDelegate?

    private var data: [URL?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        collectionView.isHidden = true
        collectionView.register(UINib(nibName: Constants.reuseId, bundle: nil), forCellWithReuseIdentifier: Constants.reuseId)
        let spacing = collectionViewLayout.minimumInteritemSpacing
        let sideInsets = collectionViewLayout.sectionInset.left + collectionViewLayout.sectionInset.right
        let size = (view.frame.width + spacing - sideInsets) / 3 - spacing
        collectionViewLayout.itemSize = CGSize(width: size, height: size)
        loadData()
    }

    @IBAction private func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    private func loadData() {
        service.allImages { [weak self] result in
            guard let self = self else {
                return
            }

            self.loader.stopAnimating()
            self.collectionView.isHidden = false

            switch result {
            case let .success(urls):
                self.data = urls
            case let .failure(error):
                self.show(error: error.localizedDescription)
            }
        }
    }
}

extension ProfileImagesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseId, for: indexPath)
        guard let cell = reuseCell as? ProfileImageCell else {
            return reuseCell
        }
        cell.model = ProfileImageModel(url: data[indexPath.row], service: service)
        return cell
    }
}

extension ProfileImagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileImageCell else {
            return
        }

        guard let image = cell.image else {
            service.image(from: data[indexPath.row]) { [weak self] result in
                if case let .success(data) = result, let image = UIImage(data: data) {
                    self?.delegate?.didSelect(image: image)
                    self?.dismiss()
                }
            }
            return
        }
        delegate?.didSelect(image: image)
        dismiss()
    }
}

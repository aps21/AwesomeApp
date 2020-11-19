//
//  ProfileImageCell.swift
//  AwesomeProject
//
//  Created by Apnnn1 on 19.11.2020.
//

import UIKit

class ProfileImageCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!

    private var hasImage = false

    var model: ProfileImageModel? {
        didSet {
            model?.load { [weak self] image in
                self?.hasImage = image != nil
                self?.imageView.image = image ?? UIImage(named: "Images/placeholder")
            }
        }
    }

    var image: UIImage? {
        hasImage ? imageView.image : nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        model?.cancelLoading()
        hasImage = false
        imageView.image = UIImage(named: "Images/placeholder")
    }
}

//
//  PhotoCell.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var photo: Photo? {
        didSet {
            guard let photo = photo else { return }

            imageView.image = photo.image
            label.text = photo.dateString
        }
    }

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        contentView.addSubview(imageView)

        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Color.divider.cgColor
        imageView.layer.borderWidth = 1.0

        imageView.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "imageView": imageView
        ]
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[imageView]|",
            options: [],
            metrics: nil,
            views: views
        )
        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[imageView]|",
            options: [],
            metrics: nil,
            views: views
        )
        NSLayoutConstraint.activate(vertical + horizontal)

        return imageView
    }()
    lazy private var label: UILabel = {
        let label = UILabel(frame: .zero)
        contentView.addSubview(label)

        label.textColor = Color.foreground
        label.backgroundColor = Color.bar.withAlphaComponent(0.7)
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "label": label
        ]
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[label(44.0)]|",
            options: [],
            metrics: nil,
            views: views
        )
        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[label]|",
            options: [],
            metrics: nil,
            views: views
        )
        NSLayoutConstraint.activate(vertical + horizontal)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

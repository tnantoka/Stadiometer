//
//  PhotoViewController.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var photo: Photo? {
        didSet {
            guard let photo = photo else { return }

            title = photo.dateString
            imageView.image = photo.image
            resultItem.title = Photo.centimeter(distance: photo.distanceString)
        }
    }

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        view.addSubview(imageView)

        imageView.contentMode = .scaleAspectFill

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

    lazy private var resultItem: UIBarButtonItem = {
        UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }()
    lazy private var trashItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashItemDidTap))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        navigationItem.rightBarButtonItem = trashItem
        toolbarItems = [resultItem]

        _ = imageView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: animated)
    }

    // MARK: - Actions

    @objc private func trashItemDidTap(sender: Any) {
        let alertController = UIAlertController(
            title: NSLocalizedString("Delete Photo", comment: ""),
            message: NSLocalizedString("Are you sure?", comment: ""),
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive,
                handler: { action in
                    self.photo?.delete()
                    self.navigationController?.popViewController(animated: true)
                }
            )
        )
        present(alertController, animated: true, completion: nil)
    }
}

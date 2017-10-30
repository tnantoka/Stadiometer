//
//  AlbumViewController.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AlbumViewController: UICollectionViewController {

    lazy private var addItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemDidTap))
    }()
    lazy private var settingsItem: UIBarButtonItem = {
        UIBarButtonItem(
            title: NSLocalizedString("Settings", comment: ""),
            style: .plain,
            target: self,
            action: #selector(settingsItemDidTap)
        )
    }()

    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        title = NSLocalizedString("Album", comment: "")

        navigationItem.leftBarButtonItem = settingsItem
        navigationItem.rightBarButtonItem = addItem

        collectionView?.backgroundColor = Color.background
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(true, animated: animated)

        photos = Photo.all()
        collectionView?.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let photoCell = cell as? PhotoCell {
            photoCell.photo = photos[indexPath.row]
        }
    
        return cell
    }

    // MARK: - Actions

    @objc private func addItemDidTap(sender: Any) {
        let measureController = MeasureViewController()
        let navController = UINavigationController(rootViewController: measureController)
        present(navController, animated: true, completion: nil)
    }

    @objc private func settingsItemDidTap(sender: Any) {
        let settingsController = SettingsViewController(style: .grouped)
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photoController = PhotoViewController()
        photoController.photo = photo
        navigationController?.pushViewController(photoController, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.bounds.width * 0.5 - 12.0
        return CGSize(width: length, height: length)
    }
}

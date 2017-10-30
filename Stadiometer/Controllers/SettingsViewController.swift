//
//  SettingsViewController.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

import AcknowList

class SettingsViewController: UITableViewController {

    let reuseIdentifier = "reuseIdentifier"

    lazy private var cancelItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelItemDidTap))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        title = NSLocalizedString("Settings", comment: "")

        navigationItem.leftBarButtonItem = cancelItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.textLabel?.text = NSLocalizedString("Acknowledgements", comment: "")

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let acknowController = AcknowListViewController()
        navigationController?.pushViewController(acknowController, animated: true)
    }

    // MARK: - Actions

    @objc private func cancelItemDidTap(sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

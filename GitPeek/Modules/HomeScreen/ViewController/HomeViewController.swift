//
//  ViewController.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties

    public let viewModel = HomeViewModel()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.backgroundImage = UIImage()
        sb.searchTextField.autocapitalizationType = .none
        return sb
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Bookmarked Users"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppColor.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.loadBookmarkedUsers()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.register(KnownUserTableViewCell.self, forCellReuseIdentifier: KnownUserTableViewCell.identifier)

        bindViewModel()
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            refreshUI()
            toggleButton.setImage(UIImage(systemName: currentToggleIcon()), for: .normal)
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(titleImageView)
        view.addSubview(titleLabel)
        view.addSubview(toggleButton)
        view.addSubview(searchBar)
        view.addSubview(resultLabel)
        view.addSubview(tableView)

        toggleButton.setImage(UIImage(systemName: currentToggleIcon()), for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)

        titleLabel.text = viewModel.titleText

        searchBar.placeholder = viewModel.searchPlaceholder
        searchBar.delegate = self

        let textField = searchBar.searchTextField
        textField.borderStyle = .none
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true

        NSLayoutConstraint.activate([
            titleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleImageView.widthAnchor.constraint(equalToConstant: 32),
            titleImageView.heightAnchor.constraint(equalToConstant: 32),

            toggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toggleButton.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 32),
            toggleButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: titleImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleButton.leadingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor),

            searchBar.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            resultLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private var isAlreadySearching = false
    
    func updateResultLableText(isSearching: Bool) {
        if isSearching == isAlreadySearching { return }
        resultLabel.text = isSearching ? "Searching..." : "Bookmarked Users"
        isAlreadySearching = isSearching
    }

    // MARK: - Theme Refresh

    private func refreshUI() {
        view.backgroundColor = AppColor.background
        titleLabel.textColor = AppColor.textPrimary
        titleImageView.tintColor = AppColor.accent
        toggleButton.tintColor = AppColor.accent
        resultLabel.textColor = AppColor.textSecondary
        tableView.backgroundColor = AppColor.tableBackground
        tableView.separatorColor = AppColor.tableSeparator

        let textField = searchBar.searchTextField
        textField.textColor = AppColor.textPrimary
        textField.backgroundColor = AppColor.cardBackground
    }

    private func currentToggleIcon() -> String {
        return traitCollection.userInterfaceStyle == .dark ? "sun.max.fill" : "moon.fill"
    }

    @objc private func toggleMode() {
        let newStyle: UIUserInterfaceStyle = overrideUserInterfaceStyle == .dark ? .light : .dark
        overrideUserInterfaceStyle = newStyle
        navigationController?.overrideUserInterfaceStyle = newStyle

        // Optional: update root window if needed
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newStyle
    }
    
    // MARK: -  Data Refresh
    
    private func bindViewModel() {
        viewModel.onUsersUpdated = { [weak self] users in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                print("Fetched \(users.count) users")
                for user in users {
                    print("Fetched \(user.login) username")
                }
            }
        }
        
        viewModel.onSearchResultEmpty = { [weak self] in
            self?.showNoResultsAlert()
        }
    }

    // MARK: -  No User Found Alert
    
    private func showNoResultsAlert() {
        let alert = UIAlertController(title: "No Users Found",
                                      message: "We couldn’t find any users matching your search.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

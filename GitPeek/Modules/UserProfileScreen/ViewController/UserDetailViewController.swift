//
//  UserDetailViewController.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.

import UIKit
import SDWebImage

class UserDetailViewController: UIViewController {

    // MARK: - Properties
    
    private let user: User
    public var viewModel: UserDetailViewModel!

    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageBackgroundCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let followersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let repoCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let repoCollectionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        return tableView
    }()

    private let refreshControl = UIRefreshControl()
    // MARK: - Init
    
    init(user: User) {
        self.user = user
        self.viewModel = UserDetailViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserDetails()
        setupUI()
        applyTheme()
        setupTableView()
        bindViewModel()
        viewModel.fetchUserData()
        viewModel.fetchPublicRepositories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyTheme()
        }
    }

    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = AppColor.background

        if let url = URL(string: user.avatar_url) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
        }
        repoCollectionLabel.text = "Repositories"
        
        refreshControl.tintColor = AppColor.accent // Customize the spinner color
        refreshControl.attributedTitle = NSAttributedString(
            string: "Refreshing...",
            attributes: [.foregroundColor: AppColor.textSecondary, .font: UIFont.systemFont(ofSize: 12)]
        )

        let statsStack = UIStackView(arrangedSubviews: [followersLabel, repoCountLabel])
        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, bioLabel, statsStack])
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainer = UIView()
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(imageBackgroundCircle)
        avatarContainer.addSubview(profileImageView)

        let mainContentStack = UIStackView(arrangedSubviews: [avatarContainer, infoStack])
        mainContentStack.axis = .horizontal
        mainContentStack.spacing = 16
        mainContentStack.alignment = .top
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainContentStack)

        view.addSubview(cardView)
        view.addSubview(repoCollectionLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            imageBackgroundCircle.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            imageBackgroundCircle.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            imageBackgroundCircle.widthAnchor.constraint(equalToConstant: 80),
            imageBackgroundCircle.heightAnchor.constraint(equalToConstant: 80),

            profileImageView.centerXAnchor.constraint(equalTo: imageBackgroundCircle.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: imageBackgroundCircle.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 72),
            profileImageView.heightAnchor.constraint(equalToConstant: 72),

            avatarContainer.widthAnchor.constraint(equalToConstant: 80),
            avatarContainer.heightAnchor.constraint(equalToConstant: 80),

            mainContentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            mainContentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mainContentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mainContentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            repoCollectionLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            repoCollectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: repoCollectionLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateUserDetails() {
        nameLabel.text = viewModel.user.login
        bioLabel.text = viewModel.user.bio ?? "No bio available"
        followersLabel.text = "\u{1F465} Followers: \(viewModel.user.followers ?? 0)"
        repoCountLabel.text = "\u{1F4E6} Repos: \(viewModel.user.public_repos ?? 0)"
    }

    // MARK: - Setup TableView
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40


        // Pull to Refresh
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        refreshControl.tintColor = AppColor.accent
        refreshControl.attributedTitle = NSAttributedString(
            string: "Pulling GitHub...",
            attributes: [.foregroundColor: AppColor.textSecondary]
        )
        tableView.refreshControl = refreshControl
    }

    // MARK: - Theme
    
    private func applyTheme() {
        cardView.backgroundColor = AppColor.cardBackground
        imageBackgroundCircle.backgroundColor = AppColor.accent.withAlphaComponent(0.2)
        nameLabel.textColor = AppColor.textPrimary
        bioLabel.textColor = AppColor.textSecondary
        followersLabel.textColor = AppColor.textPrimary
        repoCountLabel.textColor = AppColor.textPrimary
        repoCollectionLabel.textColor = AppColor.textPrimary
        view.backgroundColor = AppColor.background
    }

    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.onRepositoriesUpdated = { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }

        viewModel.onUserDataUpdated = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUserDetails()
            }
        }
    }
    
    // MARK: - Pull to Refresh Handler
    
    @objc private func didPullToRefresh() {
        viewModel.fetchPublicRepositories(reset: true)
    }
}

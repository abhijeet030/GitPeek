//
//  UserDetailViewController.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.

import UIKit
import SDWebImage

class UserDetailViewController: UIViewController {

    private let user: User
    private var viewModel: UserDetailViewModel!

    // UI Elements
    private let cardView = UIView()
    private let imageBackgroundCircle = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let followersLabel = UILabel()
    private let repoCountLabel = UILabel()
    private let repoCollectionLabel = UILabel()
    private let tableView = UITableView()

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
        setupUI()
        applyTheme()
        setupTableView()
        bindViewModel()
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
        
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        repoCollectionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        imageBackgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        repoCountLabel.translatesAutoresizingMaskIntoConstraints = false

        imageBackgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        imageBackgroundCircle.layer.cornerRadius = 40
        imageBackgroundCircle.clipsToBounds = true

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        if let url = URL(string: user.avatar_url) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
        }

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.text = user.login

        bioLabel.font = .systemFont(ofSize: 15)
        bioLabel.text = user.bio ?? "No bio available"
        bioLabel.numberOfLines = 0

        followersLabel.font = .systemFont(ofSize: 13)
        repoCountLabel.font = .systemFont(ofSize: 13)
        followersLabel.text = "👥 Followers: \(user.followers ?? 0)"
        repoCountLabel.text = "📦 Repos: \(user.public_repos ?? 0)"

        let statsStack = UIStackView(arrangedSubviews: [followersLabel, repoCountLabel])
        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually

        let infoStack = UIStackView(arrangedSubviews: [nameLabel, bioLabel, statsStack])
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let mainContentStack = UIStackView()
        mainContentStack.axis = .horizontal
        mainContentStack.spacing = 16
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false
        mainContentStack.alignment = .top

        let avatarContainer = UIView()
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(imageBackgroundCircle)
        avatarContainer.addSubview(profileImageView)

        mainContentStack.addArrangedSubview(avatarContainer)
        mainContentStack.addArrangedSubview(infoStack)

        repoCollectionLabel.font = .boldSystemFont(ofSize: 16)
        repoCollectionLabel.text = "Repositories"

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
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



    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
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
    
    
    private func bindViewModel() {
        viewModel.onRepositoriesUpdated = { [weak self] repo in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = viewModel.repositories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.identifier, for: indexPath) as! RepoTableViewCell
        cell.configure(with: repo)
        return cell
    }
}

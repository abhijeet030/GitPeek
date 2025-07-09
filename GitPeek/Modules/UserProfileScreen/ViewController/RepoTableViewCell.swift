//
//  RepoTableViewCell.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

class RepoTableViewCell: UITableViewCell {

    static let identifier = "RepoTableViewCell"

    // MARK: - UI Elements

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = AppColor.textPrimary
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let starLabel = RepoTableViewCell.makeStatLabel(icon: "⭐")
    private let forkLabel = RepoTableViewCell.makeStatLabel(icon: "🍴")
    private let watcherLabel = RepoTableViewCell.makeStatLabel(icon: "👁")

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        statsStack.addArrangedSubview(starLabel)
        statsStack.addArrangedSubview(forkLabel)
        statsStack.addArrangedSubview(watcherLabel)

        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(descriptionLabel)
        verticalStack.addArrangedSubview(statsStack)

        // Padding for the entire cell (contentView -> containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            verticalStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configuration

    func configure(with repo: Repository) {
        nameLabel.text = repo.name
        descriptionLabel.text = repo.description ?? "No description available"
        starLabel.text = "⭐ \(repo.stargazers_count)"
        forkLabel.text = "🍴 \(repo.forks_count)"
        watcherLabel.text = "👁 \(repo.watchers_count)"
    }

    // MARK: - Helpers

    private static func makeStatLabel(icon: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = AppColor.textSecondary
        label.text = icon
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }
}


//
//  RepoTableViewCell.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

class RepoTableViewCell: UITableViewCell {

    static let identifier = "RepoTableViewCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textColor = AppColor.textPrimary
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = AppColor.textSecondary
        return label
    }()

    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = AppColor.textPrimary
        return label
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = AppColor.cardBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(descriptionLabel)
        verticalStack.addArrangedSubview(statsLabel)

        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with repo: Repository) {
        nameLabel.text = repo.name
        descriptionLabel.text = repo.description ?? "No description"
        statsLabel.text = "⭐ Stars: \(repo.stargazers_count)    👁 Forks: \(repo.forks_count)"
    }
}


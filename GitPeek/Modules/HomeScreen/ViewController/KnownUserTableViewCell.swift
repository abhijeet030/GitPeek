//
//  KnownUserTableViewCell.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit
import SDWebImage

class KnownUserTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let identifier = "KnownUserTableViewCell"

    private var isBookmarked: Bool = false
    
    var onBookmarkTapped: ((Bool) -> Void)?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        iv.widthAnchor.constraint(equalToConstant: 48).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return iv
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppColor.textPrimary
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 2
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColor.textPrimary
        return label
    }()
    
    let repoCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColor.textPrimary
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = AppColor.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let secondaryHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let mainContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyTheme()
        }
    }

    // MARK: - Setup
    
    private func setupUI() {
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        
        applyTheme()

        secondaryHorizontalStack.addArrangedSubview(followersLabel)
        secondaryHorizontalStack.addArrangedSubview(repoCountLabel)

        verticalStack.addArrangedSubview(nameLabel)
        verticalStack.addArrangedSubview(subtitleLabel)
        verticalStack.addArrangedSubview(secondaryHorizontalStack)

        verticalStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        bookmarkButton.setContentHuggingPriority(.required, for: .horizontal)

        mainContentStack.addArrangedSubview(profileImageView)
        mainContentStack.addArrangedSubview(verticalStack)
        mainContentStack.addArrangedSubview(bookmarkButton)

        contentView.addSubview(mainContentStack)
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainContentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainContentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainContentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainContentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.login
        subtitleLabel.text = user.bio ?? "—"
        followersLabel.text = "👥 \(user.followers ?? 0)"
        repoCountLabel.text = "📦 \(user.public_repos ?? 0)"
        
        self.isBookmarked = user.isBookmarked
        updateBookmarkIcon()

        if let url = URL(string: user.avatar_url) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
    }

    // MARK: - Bookmark Related Task
    
    @objc private func didTapBookmark() {
        isBookmarked.toggle()
        updateBookmarkIcon()
        onBookmarkTapped?(isBookmarked)
    }
    
    private func updateBookmarkIcon() {
        let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    // MARK: - Theme Refresh
    
    private func applyTheme() {
        backgroundColor = AppColor.cardBackground
        contentView.backgroundColor = AppColor.cardBackground

        nameLabel.textColor = AppColor.textPrimary
        subtitleLabel.textColor = AppColor.textSecondary
        followersLabel.textColor = AppColor.textPrimary
        repoCountLabel.textColor = AppColor.textPrimary
        bookmarkButton.tintColor = AppColor.accent

        let selectedView = UIView()
        selectedView.backgroundColor = AppColor.tableSelectedCell
        selectedBackgroundView = selectedView
    }

}


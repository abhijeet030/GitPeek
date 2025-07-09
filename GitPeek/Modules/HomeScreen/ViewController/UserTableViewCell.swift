//
//  UserTableViewCell.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {
    
    // MARK: - Public
    
    static let identifier = "UserTableViewCell"
    var onBookmarkTapped: ((Bool) -> Void)?
    
    // MARK: - Private Properties
    
    private var isBookmarked: Bool = false
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48)
        ])
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = AppColor.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Trait Change Handling
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyTheme()
        }
    }

    // MARK: - Configuration
    
    func configure(with user: User) {
        nameLabel.text = user.login
        isBookmarked = user.isBookmarked
        updateBookmarkIcon()
        
        if let url = URL(string: user.avatar_url) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
    }

    // MARK: - Private Setup
    
    private func setupUI() {
        contentView.addSubview(mainStack)
        mainStack.addArrangedSubview(profileImageView)
        mainStack.addArrangedSubview(nameLabel)
        mainStack.addArrangedSubview(bookmarkButton)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        applyTheme()
    }
    
    private func applyTheme() {
        backgroundColor = AppColor.cardBackground
        contentView.backgroundColor = AppColor.cardBackground
        nameLabel.textColor = AppColor.textPrimary
        bookmarkButton.tintColor = AppColor.accent
        
        let selectedView = UIView()
        selectedView.backgroundColor = AppColor.tableSelectedCell
        selectedBackgroundView = selectedView
    }
    
    // MARK: - Bookmark Handling
    
    @objc private func didTapBookmark() {
        isBookmarked.toggle()
        updateBookmarkIcon()
        onBookmarkTapped?(isBookmarked)
    }
    
    private func updateBookmarkIcon() {
        let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
}

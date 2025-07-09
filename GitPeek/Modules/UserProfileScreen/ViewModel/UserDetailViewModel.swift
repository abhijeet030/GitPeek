//
//  UserDetailViewModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

class UserDetailViewModel {
    
    // MARK: - Properties
    private(set) var user: User {
        didSet {
            onUserDataUpdated?(user)
        }
    }

    private(set) var repositories: [Repository] = [] {
        didSet {
            onRepositoriesUpdated?(repositories)
        }
    }

    var onRepositoriesUpdated: (([Repository]) -> Void)?
    var onUserDataUpdated: ((User) -> Void)?

    init(user: User) {
        self.user = user
    }

    var username: String {
        return user.login
    }

    var bio: String {
        return user.bio ?? "No bio available"
    }

    var avatarURL: String {
        return user.avatar_url
    }

    var followers: Int {
        return user.followers ?? 0
    }

    var publicReposCount: Int {
        return user.public_repos ?? 0
    }

    private var currentPage = 1
    private var isLoadingMore = false
    private var canLoadMore = true
    
    // MARK: - API Call: Repositories
    func fetchPublicRepositories(reset: Bool = false) {
            if isLoadingMore { return }

            if reset {
                currentPage = 1
                canLoadMore = true
                repositories = []
            }

            guard canLoadMore else { return }

            isLoadingMore = true
            let urlStr = "https://api.github.com/users/\(user.login)/repos?page=\(currentPage)&per_page=20"

            NetworkManager.shared.request(urlString: urlStr) { [weak self] (result: Result<[Repository], NetworkManager.NetworkError>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoadingMore = false

                    switch result {
                    case .success(let repos):
                        if repos.isEmpty {
                            self.canLoadMore = false
                        } else {
                            self.repositories += repos
                            self.currentPage += 1
                        }

                    case .failure(let error):
                        print("Pagination error: \(error)")
                        self.canLoadMore = false
                    }
                }
            }
        }

    // MARK: - API Call: User Details
    func fetchUserData() {
        let detailURL = "https://api.github.com/users/\(user.login)"

        NetworkManager.shared.request(urlString: detailURL) { [weak self] (result: Result<User, NetworkManager.NetworkError>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(var fullUser):
                    if self.user.isBookmarked {
                        fullUser.isBookmarked = true
                        CoreDataManager.shared.saveBookmark(fullUser)
                    }
                    self.user = fullUser

                case .failure(let error):
                    print("Failed to fetch user data: \(error)")
                    // Optionally trigger update with existing data
                    self.onUserDataUpdated?(self.user)
                }
            }
        }
    }
}

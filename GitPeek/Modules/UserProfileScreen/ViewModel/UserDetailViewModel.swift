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
            if user != oldValue {
                CoreDataManager.shared.saveBookmark(self.user)
            }
            onUserDataUpdated?(user)
        }
    }

    private(set) var repositories: [RepositoryModel] = [] {
        didSet {
            onRepositoriesUpdated?(repositories)
        }
    }

    var onRepositoriesUpdated: (([RepositoryModel]) -> Void)?
    var onUserDataUpdated: ((User) -> Void)?

    init(user: User) {
        self.user = user
    }

    var username: String { user.login }
    var bio: String { user.bio ?? "No bio available" }
    var avatarURL: String { user.avatar_url }
    var followers: Int { user.followers ?? 0 }
    var publicReposCount: Int { user.public_repos ?? 0 }

    private var currentPage = 1
    private var isLoadingMore = false
    private var canLoadMore = true

    // MARK: - API Call: Repositories
    
    func fetchPublicRepositories(reset: Bool = false) {
        guard !isLoadingMore else { return }
        isLoadingMore = true

        if NetworkMonitor.shared.isConnected {
            fetchPublicRepositoriesOnline(reset)
        } else {
            fallbackToLocalFetchReposrity()
        }
    }
    
    private func fallbackToLocalFetchReposrity() {
        defer { isLoadingMore = false }
        guard let bookmarkedUser = CoreDataManager.shared.fetchBookmarkedUser(by: user.login),
              let storedRepos = bookmarkedUser.repositories as? Set<Repository> else {
            print("No local data found for user \(user.login)")
            return
        }

        let repoModels: [RepositoryModel] = storedRepos.map { repo in
            RepositoryModel(
                name: repo.name ?? "",
                html_url: repo.html_url ?? "",
                description: repo.repoDescription,
                language: repo.language,
                stargazers_count: Int(repo.stargazers_count),
                forks_count: Int(repo.forks_count),
                watchers_count: Int(repo.watchers_count)
            )
        }

        self.repositories = repoModels.sorted { $0.name < $1.name }
    }

    private func fetchPublicRepositoriesOnline(_ reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            repositories = []
        }

        guard canLoadMore else {
            isLoadingMore = false
            return
        }

        let urlStr = "https://api.github.com/users/\(user.login)/repos?page=\(currentPage)&per_page=20"

        NetworkManager.shared.request(urlString: urlStr) { [weak self] (result: Result<[RepositoryModel], NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingMore = false

                switch result {
                case .success(let repos):
                    if repos.isEmpty {
                        self.canLoadMore = false
                    } else {
                        self.repositories += repos
                        if self.user.isBookmarked {
                            CoreDataManager.shared.saveBookmark(self.user, repositories: self.repositories)
                        }
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
    
    private var isFetchingUserData = false

    func fetchUserData() {
        guard !isFetchingUserData, NetworkMonitor.shared.isConnected else { return }
        isFetchingUserData = true

        let detailURL = "https://api.github.com/users/\(user.login)"
        NetworkManager.shared.request(urlString: detailURL) { [weak self] (result: Result<User, NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFetchingUserData = false

                switch result {
                case .success(let fullUser):
                    self.user = fullUser

                case .failure(let error):
                    print("Failed to fetch user data: \(error)")
                    self.onUserDataUpdated?(self.user)
                }
            }
        }
    }
}

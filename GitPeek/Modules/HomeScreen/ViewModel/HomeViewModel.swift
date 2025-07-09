//
//  HomeViewModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

final class HomeViewModel {

    // MARK: - Public Properties

    let titleText = "GitPeek"
    let searchPlaceholder = "Search GitHub Users"
    var onUsersUpdated: (([User]) -> Void)?

    var users: [User] = [] {
        didSet {
            onUsersUpdated?(users)
        }
    }

    // MARK: - Private Properties

    private var hasSearched = false
    private var hasExecutedDebounce = false
    private var debounceWorkItem: DispatchWorkItem?
    private let bookmarkQueue = DispatchQueue(label: "com.gitpeek.bookmarkQueue")

    // MARK: - Search Entry Point

    func filterContent(with query: String) {
        if !hasSearched {
            users = []
        }

        if NetworkMonitor.shared.isConnected {
            debounceOnlineSearch(query)
        } else {
            fallbackToLocalSearch(query: query)
        }
    }

    // MARK: - Debounced API Search

    private func debounceOnlineSearch(_ query: String) {
        debounceWorkItem?.cancel()
        hasExecutedDebounce = false

        let task = DispatchWorkItem { [weak self] in
            self?.hasExecutedDebounce = true
            self?.performSearch(query: query)
        }

        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }

    private func performSearch(query: String) {
        hasSearched = true

        guard !query.isEmpty else {
            users = []
            return
        }

        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://api.github.com/search/users?q=\(escapedQuery)"
        let bookmarkedUsers = fetchBookmarkedUsers()

        NetworkManager.shared.request(urlString: urlStr) { [weak self] (result: Result<SearchResult, NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let data):
                    let enrichedUsers = data.items.map { user in
                        bookmarkedUsers.first(where: { $0.login == user.login }) ?? user
                    }
                    self.users = enrichedUsers

                case .failure(let error):
                    print("❌ API Error: \(error)")
                    self.fallbackToLocalSearch(query: query)
                }
            }
        }
    }

    // MARK: - Local Bookmarks Fallback

    private func fallbackToLocalSearch(query: String) {
        let allBookmarks = CoreDataManager.shared.fetchAllBookmarks()

        let filtered = allBookmarks.filter {
            ($0.login?.lowercased().contains(query.lowercased()) ?? false)
        }

        self.users = filtered.map {
            User(
                login: $0.login ?? "",
                avatar_url: $0.avatar_url ?? "",
                bio: $0.bio,
                followers: Int($0.followers),
                public_repos: Int($0.public_repos),
                isBookmarked: true
            )
        }
    }

    private func fetchBookmarkedUsers() -> [User] {
        let bookmarks = CoreDataManager.shared.fetchAllBookmarks()

        return bookmarks.map {
            User(
                login: $0.login ?? "",
                avatar_url: $0.avatar_url ?? "",
                bio: $0.bio,
                followers: Int($0.followers),
                public_repos: Int($0.public_repos),
                isBookmarked: true
            )
        }
    }

    // MARK: - Bookmarks Management

    func loadBookmarkedUsers() {
        let bookmarks = CoreDataManager.shared.fetchAllBookmarks()

        guard !bookmarks.isEmpty else {
            users = []
            return
        }

        self.users = bookmarks.map {
            User(
                login: $0.login ?? "",
                avatar_url: $0.avatar_url ?? "",
                bio: $0.bio,
                followers: Int($0.followers),
                public_repos: Int($0.public_repos),
                isBookmarked: true
            )
        }
    }

    func saveBookMarkedUser(_ user: User) {
        bookmarkQueue.async { [weak self] in
            guard self != nil else { return }

            let detailURL = "https://api.github.com/users/\(user.login)"
            let semaphore = DispatchSemaphore(value: 0)

            NetworkManager.shared.request(urlString: detailURL) { (result: Result<User, NetworkManager.NetworkError>) in
                let userToSave: User

                switch result {
                case .success(var fullUser):
                    fullUser.isBookmarked = true
                    userToSave = fullUser

                case .failure:
                    var fallbackUser = user
                    fallbackUser.isBookmarked = true
                    userToSave = fallbackUser
                }

                CoreDataManager.shared.saveBookmark(userToSave)
                semaphore.signal()
            }

            semaphore.wait()
        }
    }

    func removeBookMarkedUser(_ user: User) {
        CoreDataManager.shared.removeBookmark(login: user.login)
        loadBookmarkedUsers()
    }

    // MARK: - Reset State

    func clearSearchData() {
        hasSearched = false
        loadBookmarkedUsers()

        if !hasExecutedDebounce {
            debounceWorkItem?.cancel()
        }
    }

    // MARK: - Network Response Models

    private struct SearchResult: Decodable {
        let items: [User]
    }
}

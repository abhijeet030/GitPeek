//
//  HomeViewModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

class HomeViewModel {

    let titleText = "GitPeek"
    let searchPlaceholder = "Search GitHub Users"
    private var hasSearched = false


    var users: [User] = [] {
        didSet {
            onUsersUpdated?(users)
        }
    }

    func loadBookmarkedUsers() {
        let bookmarks = CoreDataManager.shared.fetchAllBookmarks()

        guard !bookmarks.isEmpty else {
            users = []
            return
        }

        users = bookmarks.map {
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
    
    var onUsersUpdated: (([User]) -> Void)?

    private var debounceWorkItem: DispatchWorkItem?
    private var hasExecutedDebounce: Bool = false

    func filterContent(with query: String) {
        if !hasSearched {
            self.users = []
        }
        
        if NetworkMonitor.shared.isConnected {
            filterContentOnline(with: query)
        } else {
            fallbackToLocalSearch(for: query)
        }
    }
    
    private func filterContentOnline(with query: String) {
        debounceWorkItem?.cancel()
        hasExecutedDebounce = false

        let task = DispatchWorkItem { [weak self] in
            self?.hasExecutedDebounce = true
            self?.performSearch(query: query)
        }

        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    

    private func performSearch(query: String) {
        hasSearched = true

        guard !query.isEmpty else {
            self.users = []
            return
        }

        let queryEscaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://api.github.com/search/users?q=\(queryEscaped)"

        NetworkManager.shared.request(urlString: urlStr) { [weak self] (result: Result<SearchResult, NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let bookmarks = CoreDataManager.shared.fetchAllBookmarks()
                    let bookmarkedLogins = Set(bookmarks.compactMap { $0.login })

                    let enriched = data.items.map { user -> User in
                        var enrichedUser = user
                        enrichedUser.isBookmarked = bookmarkedLogins.contains(user.login)
                        return enrichedUser
                    }

                    self?.users = enriched
                case .failure(let error):
                    print("Error: \(error)")
                    self?.fallbackToLocalSearch(for: query)
                }
            }
        }
    }
    
    private func fallbackToLocalSearch(for query: String) {
        let bookmarks = CoreDataManager.shared.fetchAllBookmarks()

        let filtered = bookmarks.filter { user in
            let name = user.login?.lowercased() ?? ""
            return name.contains(query.lowercased())
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

    private struct SearchResult: Decodable {
        let items: [User]
    }
    
    func clearSearchData() {
        hasSearched = false
        loadBookmarkedUsers()
        
        if hasExecutedDebounce == false {
            debounceWorkItem?.cancel()
        }
    }

    private let bookmarkQueue = DispatchQueue(label: "com.gitpeek.bookmarkQueue")
    
    func saveBookMarkedUser(_ user: User) {
        bookmarkQueue.async { [weak self] in
            guard self != nil else { return }

            let detailURL = "https://api.github.com/users/\(user.login)"

            let semaphore = DispatchSemaphore(value: 0)

            NetworkManager.shared.request(urlString: detailURL) { (result: Result<User, NetworkManager.NetworkError>) in
                switch result {
                case .success(let fullUser):
                    var enrichedUser = fullUser
                    enrichedUser.isBookmarked = true
                    CoreDataManager.shared.saveBookmark(enrichedUser)

                case .failure(let error):
                    print("⚠️ Failed to fetch full user details: \(error.localizedDescription)")
                    var fallbackUser = user
                    fallbackUser.isBookmarked = true
                    CoreDataManager.shared.saveBookmark(fallbackUser)
                }
                semaphore.signal()
            }

            semaphore.wait()
        }
    }

    
    func removeBookMarkedUser(_ user: User) {
        CoreDataManager.shared.removeBookmark(login: user.login)
        loadBookmarkedUsers()
    }
}

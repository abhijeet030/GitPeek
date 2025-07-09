//
//  UserDetailViewModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

class UserDetailViewModel {
    
    // MARK: - Properties
    private let user: User
    private(set) var repositories: [Repository] = [] {
        didSet {
            onRepositoriesUpdated?(repositories)
        }
    }

    var onRepositoriesUpdated: (([Repository]) -> Void)?
    
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

    // MARK: - API Call
    func fetchPublicRepositories() {
        let urlStr = "https://api.github.com/users/\(user.login)/repos"
        
        NetworkManager.shared.request(urlString: urlStr) { [weak self] (result: Result<[Repository], NetworkManager.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let repos):
                    self?.repositories = repos
                    for (index, repo) in repos.enumerated() {
                        print("""
                        ----- Repo \(index + 1) -----
                        Name: \(repo.name)
                        URL: \(repo.html_url)
                        Description: \(repo.description ?? "No description")
                        Language: \(repo.language ?? "Not specified")
                        Stars: \(repo.stargazers_count)
                        Forks: \(repo.forks_count)
                        """)
                    }
                case .failure(let error):
                    print("Error fetching repos: \(error)")
                    self?.repositories = []
                }
            }
        }
    }
    
    
}

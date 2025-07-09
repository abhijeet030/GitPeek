//
//  HomeModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

struct User: Decodable {
    let login: String
    let avatar_url: String
    var bio: String?
    var followers: Int?
    var public_repos: Int?
    
    var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatar_url
        case bio
        case followers
        case public_repos
    }
}



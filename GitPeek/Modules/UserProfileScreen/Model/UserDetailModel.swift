//
//  UserDetailModel.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

struct Repository: Decodable {
    let name: String
    let html_url: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let forks_count: Int
}

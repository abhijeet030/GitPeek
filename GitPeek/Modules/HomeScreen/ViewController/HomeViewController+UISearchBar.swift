//
//  HomeViewController+UISearchBar.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            updateResultLableText(isSearching: true)
            viewModel.filterContent(with: trimmedText)
        } else {
            updateResultLableText(isSearching: false)
            viewModel.clearSearchData()
        }
    }
}

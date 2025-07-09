//
//  HomeViewController+UITableView.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import UIKit

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = viewModel.users[indexPath.row]
        if user.isBookmarked {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: KnownUserTableViewCell.identifier, for: indexPath) as? KnownUserTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: user)
            
            cell.onBookmarkTapped = { isBookmarked in
                if isBookmarked {
                    print("Debug : BookMarked User \(user.login)")
                    self.viewModel.saveBookMarkedUser(user)
                } else {
                    print("Debug : BookMark Removed User \(user.login)")
                    self.viewModel.removeBookMarkedUser(user)
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: user)
            
            cell.onBookmarkTapped = { isBookmarked in
                if isBookmarked {
                    print("Debug : BookMarked User \(user.login)")
                    self.viewModel.saveBookMarkedUser(user)
                } else {
                    print("Debug : BookMark Removed User \(user.login)")
                    self.viewModel.removeBookMarkedUser(user)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = viewModel.users[indexPath.row]
        let detailVC = UserDetailViewController(user: selectedUser)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

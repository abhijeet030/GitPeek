//
//  CoreDataManager.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let context: NSManagedObjectContext
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("No AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
    }
    
    func saveBookmark(_ user: User) {
        let bookmark = BookmarkedUser(context: context)
        bookmark.login = user.login
        bookmark.avatar_url = user.avatar_url
        bookmark.bio = user.bio
        bookmark.followers = Int64(user.followers ?? 0)
        bookmark.public_repos = Int64(user.public_repos ?? 0)
        
        saveContext()
    }
    
    func removeBookmark(login: String) {
        let fetch: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
        fetch.predicate = NSPredicate(format: "login == %@", login)
        if let result = try? context.fetch(fetch), let object = result.first {
            context.delete(object)
            saveContext()
        }
    }
    
    func isBookmarked(login: String) -> Bool {
        let fetchRequest: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check bookmark status for \(login): \(error)")
            return false
        }
    }
    
    func fetchAllBookmarks() -> [BookmarkedUser] {
        let fetch: NSFetchRequest<BookmarkedUser> = BookmarkedUser.fetchRequest()
        do {
            return try context.fetch(fetch)
        } catch {
            print("Failed to fetch bookmarks: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}


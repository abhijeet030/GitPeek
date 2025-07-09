//
//  NetworkManager.swift
//  GitPeek
//
//  Created by Abhijeet Ranjan  on 09/07/25.
//

import Foundation

final class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    enum NetworkError: Error {
        case invalidURL
        case requestFailed
        case decodingFailed
    }

    func request<T: Decodable>(
        urlString: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.requestFailed))
                return
            }

            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(.decodingFailed))
            }
        }

        task.resume()
    }
}

//
//  TodosApiClient.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decoding(Error)
    case underlying(Error)
}

protocol TodosAPI {
    func fetchTodos(
        page: Int,
        limit: Int,
        completion: @escaping (Result<PaginatedTodos, Error>) -> Void
    )
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void)
}

final class TodosAPIClient: TodosAPI {
    private let session: URLSession
    private let baseURL: URL
    
    private var cachedTodos: [Todo] = []
    private var cachedUsers: [User]?
    
    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchTodos(
        page: Int,
        limit: Int,
        completion: @escaping (Result<PaginatedTodos, Error>) -> Void
    ) {
        if page > 1, !cachedTodos.isEmpty {
            respondWithCachedTodos(page: page, limit: limit, completion: completion)
            return
        }
        
        guard let url = URL(string: "todos", relativeTo: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error {
                completion(.failure(APIError.underlying(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            do {
                let todos = try JSONDecoder().decode([Todo].self, from: data)
                self.cachedTodos = todos
                self.respondWithCachedTodos(page: page, limit: limit, completion: completion)
            } catch {
                completion(.failure(APIError.decoding(error)))
            }
        }
        
        task.resume()
        }

        func fetchUsers(
            completion: @escaping (Result<[User], Error>) -> Void
        ) {
            if let cachedUsers {
                completion(.success(cachedUsers))
                return
            }

            guard let url = URL(string: "users", relativeTo: baseURL) else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error {
                    completion(.failure(APIError.underlying(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                guard (200..<300).contains(httpResponse.statusCode) else {
                    completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }

                guard let data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    self?.cachedUsers = users
                    completion(.success(users))
                } catch {
                    completion(.failure(APIError.decoding(error)))
                }
            }
        
        task.resume()
    }
    
    private func respondWithCachedTodos(
        page: Int,
        limit: Int,
        completion: @escaping (Result<PaginatedTodos, Error>) -> Void
    ) {
        completion(.success(Self.paginate(todos: cachedTodos, page: page, limit: limit)))
    }
    
    private static func paginate(todos: [Todo], page: Int, limit: Int) -> PaginatedTodos {
        guard page > 0 else {
            return PaginatedTodos(todos: [], currentPage: page, pageSize: limit, totalCount: todos.count)
        }
        let startIndex = max(0, (page - 1) * limit)
        let endIndex = min(startIndex + limit, todos.count)
        let pageTodos = startIndex < endIndex ? Array(todos[startIndex..<endIndex]) : []
        
        return PaginatedTodos(
            todos: pageTodos,
            currentPage: page,
            pageSize: limit,
            totalCount: todos.count
        )
    }
}

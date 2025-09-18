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
}

final class TodosAPIClient: TodosAPI {
    private let session: URLSession
    private let baseURL: URL
    
    init(session: URLSession = .shared, baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchTodos(
        page: Int,
        limit: Int,
        completion: @escaping (Result<PaginatedTodos, Error>) -> Void
    ) {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("todos"), resolvingAgainstBaseURL: false) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "_page", value: String(page)),
            URLQueryItem(name: "_limit", value: String(limit))
        ]
        
        guard let url = components.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
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
                let totalCount = Self.totalCount(from: httpResponse)
                let paginated = PaginatedTodos(
                    todos: todos,
                    currentPage: page,
                    pageSize: limit,
                    totalCount: totalCount
                )
                completion(.success(paginated))
            } catch {
                completion(.failure(APIError.decoding(error)))
            }
        }
        
        task.resume()
    }
    
    private static func totalCount(from response: HTTPURLResponse) -> Int? {
        guard let value = response.value(forHTTPHeaderField: "X-Total-Count"),
              let total = Int(value) else {
            return nil
        }
        return total
    }
}

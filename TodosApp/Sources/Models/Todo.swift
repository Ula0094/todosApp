//
//  Todo.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

struct Todo: Codable, Identifiable {
    let id: Int
    let title: String
    let completed: Bool
    let userId: Int?
}

struct PaginatedTodos {
    let todos: [Todo]
    let currentPage: Int
    let pageSize: Int
    let totalCount: Int?
    
    var hasMore: Bool {
        if let totalCount {
            return currentPage * pageSize < totalCount
        }
        return !todos.isEmpty
    }
    
    var nextPage: Int? {
        hasMore ? currentPage + 1 : nil
    }
}

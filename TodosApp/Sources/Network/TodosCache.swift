//
//  TodosCache.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 19/09/25.
//

import Foundation

protocol TodosCaching {
    func loadTodos() throws -> [Todo]
    func saveTodos(_ todos: [Todo]) throws
}

struct TodosFileCache: TodosCaching {
    private let fileURL: URL
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            fileURL = cachesDirectory.appendingPathComponent("todosCache.json")
        } else {
            fileURL = fileManager.temporaryDirectory.appendingPathComponent("todosCache.json")
        }
    }
    
    func loadTodos() throws -> [Todo] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else {
            return []
        }
        
        return try JSONDecoder().decode([Todo].self, from: data)
    }
    
    func saveTodos(_ todos: [Todo]) throws {
        let data = try JSONEncoder().encode(todos)
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }
}

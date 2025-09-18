//
//  TodoListViewModel.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

struct TodoListItemViewModel: Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let isCompleted: Bool
    
    init(todo: Todo) {
        id = todo.id
        title = todo.title.capitalized
        let userInfo = todo.userId.map { " • User #\($0)" } ?? ""
        subtitle = "Task #\(todo.id)" + userInfo
        isCompleted = todo.completed
    }
}

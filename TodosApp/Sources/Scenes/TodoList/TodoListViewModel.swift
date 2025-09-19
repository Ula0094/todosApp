//
//  TodoListViewModel.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

struct TodoListItemViewModel {
    let id: Int
    let title: String
    let subtitle: String
    let isCompleted: Bool
    
    init(todo: Todo, user: User?) {
        id = todo.id
        title = todo.title.capitalized
        subtitle = user?.name ?? "Unknown User"
        isCompleted = todo.completed
    }
}

//
//  TodoDetailsViewModel.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 19/09/25.
//

import Foundation

struct TodoDetailsViewModel {
    struct InfoItem {
        let title: String
        let value: String
    }
    
    let navigationTitle: String
    let items: [InfoItem]
    
    init(todo: Todo, user: User?) {
        navigationTitle = "Todo #\(todo.id)"
        
        var details: [InfoItem] = [
            InfoItem(title: "Title", value: todo.title.capitalized),
            InfoItem(title: "Completed", value: todo.completed ? "Yes" : "No")
        ]
        
        if let user {
            details.append(InfoItem(title: "User Name", value: user.name))
            if let username = user.username, !username.isEmpty {
                details.append(InfoItem(title: "Username", value: username))
            }
            if let email = user.email, !email.isEmpty {
                details.append(InfoItem(title: "Email", value: email))
            }
            if let phone = user.phone, !phone.isEmpty {
                details.append(InfoItem(title: "Phone", value: phone))
            }
            if let website = user.website, !website.isEmpty {
                details.append(InfoItem(title: "Website", value: website))
            }
        } else {
            details.append(InfoItem(title: "User", value: "Unknown User"))
        }
        
        items = details
    }
}

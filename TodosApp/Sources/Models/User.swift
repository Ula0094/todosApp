//
//  User.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 19/09/25.
//

import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let name: String
    let username: String?
    let email: String?
    let phone: String?
    let website: String?
}

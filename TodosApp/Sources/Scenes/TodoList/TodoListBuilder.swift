//
//  MainModuleBuilder.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import UIKit

enum TodoListBuilder {
    static func build() -> UIViewController {
        let apiClient = TodosAPIClient()
        let presenter = TodoListPresenter(apiClient: apiClient, pageSize: 20)
        let viewController = TodoListViewController(presenter: presenter)
        return viewController
    }
}

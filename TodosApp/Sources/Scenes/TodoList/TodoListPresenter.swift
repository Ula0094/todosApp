//
//  TodoListPresenter.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

protocol TodoListView: AnyObject {
    func showLoading(_ isLoading: Bool)
    func setFooterLoading(_ isLoading: Bool)
    func showTodos(_ viewModels: [TodoListItemViewModel], reset: Bool)
    func showError(message: String)
    func showTodoDetails(_ viewModel: TodoDetailsViewModel)
}

protocol TodoListPresenting {
    func attach(view: TodoListView)
    func viewDidLoad()
    func didPullToRefresh()
    func didReachItem(at index: Int)
    func didSelectTodo(with id: Int)
}

final class TodoListPresenter: TodoListPresenting {
    private weak var view: TodoListView?
    private let apiClient: TodosAPI
    private let pageSize: Int
    private var paginationState = PaginationState()
    private var cachedViewModels: [TodoListItemViewModel] = []
    
    private var cachedTodos: [Todo] = []
    private var usersById: [Int: User] = [:]
    
    init(apiClient: TodosAPI, pageSize: Int = 20) {
        self.apiClient = apiClient
        self.pageSize = pageSize
    }
    
    func attach(view: TodoListView) {
        self.view = view
    }
    
    func viewDidLoad() {
        loadFirstPage()
    }
    
    func didPullToRefresh() {
        loadFirstPage()
    }
    
    func didReachItem(at index: Int) {
        guard index >= cachedViewModels.count - 5 else { return }
        loadNextPage()
    }
    
    func didSelectTodo(with id: Int) {
        guard let todo = cachedTodos.first(where: { $0.id == id }) else { return }
        let user = todo.userId.flatMap { usersById[$0] }
        let detailsViewModel = TodoDetailsViewModel(todo: todo, user: user)
        view?.showTodoDetails(detailsViewModel)
    }
    
    private func loadFirstPage() {
        paginationState.reset()
        cachedViewModels.removeAll()
        cachedTodos.removeAll()
        view?.showLoading(true)
        fetchUsersIfNeeded { [weak self] in
            self?.loadNextPage(reset: true)
        }
    }
    
    private func loadNextPage(reset: Bool = false) {
        guard let page = paginationState.startLoadingNextPage() else { return }
        view?.setFooterLoading(true)
        
        apiClient.fetchTodos(page: page, limit: pageSize) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.view?.setFooterLoading(false)
                switch result {
                case let .success(pageResponse):
                    self.paginationState.completeLoading(with: pageResponse)
                    let newViewModels = pageResponse.todos.map { todo in
                        let user = todo.userId.flatMap { self.usersById[$0] }
                        return TodoListItemViewModel(todo: todo, user: user)
                    }
                    if reset {
                        self.cachedTodos = pageResponse.todos
                        self.cachedViewModels = newViewModels
                    } else {
                        self.cachedTodos.append(contentsOf: pageResponse.todos)
                        self.cachedViewModels.append(contentsOf: newViewModels)
                    }
                    self.view?.showLoading(false)
                    self.view?.showTodos(newViewModels, reset: reset)
                case let .failure(error):
                    self.paginationState.completeLoadingWithError()
                    self.view?.showLoading(false)
                    self.view?.showError(message: Self.errorMessage(from: error))
                }
            }
        }
    }
    
    private func fetchUsersIfNeeded(completion: @escaping () -> Void) {
        guard usersById.isEmpty else {
            completion()
            return
        }
        
        apiClient.fetchUsers { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(users):
                    self.usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
                case let .failure(error):
                    self.view?.showError(message: Self.errorMessage(from: error))
                }
                completion()
            }
        }
    }
    
    private static func errorMessage(from error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return "Failed to build request URL."
            case .invalidResponse:
                return "Received invalid server response."
            case let .serverError(statusCode):
                return "Server returned status code \(statusCode)."
            case let .decoding(decodingError):
                return "Failed to decode response: \(decodingError.localizedDescription)"
            case let .underlying(underlyingError):
                return underlyingError.localizedDescription
            }
        }
        return error.localizedDescription
    }
}

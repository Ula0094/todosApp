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
}

protocol TodoListPresenting {
    func attach(view: TodoListView)
    func viewDidLoad()
    func didPullToRefresh()
    func didReachItem(at index: Int)
}

final class TodoListPresenter: TodoListPresenting {
    private weak var view: TodoListView?
    private let apiClient: TodosAPI
    private let pageSize: Int
    private var paginationState = PaginationState()
    private var cachedViewModels: [TodoListItemViewModel] = []
    
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
    
    private func loadFirstPage() {
        paginationState.reset()
        cachedViewModels.removeAll()
        view?.showLoading(true)
        loadNextPage(reset: true)
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
                    let newViewModels = pageResponse.todos.map(TodoListItemViewModel.init)
                    if reset {
                        self.cachedViewModels = newViewModels
                    } else {
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

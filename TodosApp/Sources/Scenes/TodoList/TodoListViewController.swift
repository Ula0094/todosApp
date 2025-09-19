//
//  TodoListViewController.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import UIKit

final class TodoListViewController: UIViewController {
    private let presenter: TodoListPresenting
    
    private var allItems: [TodoListItemViewModel] = []
    private var filteredItems: [TodoListItemViewModel] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = activityIndicator
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search by title or user"
        controller.searchBar.delegate = self
        return controller
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        return control
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        return indicator
    }()
    
    init(presenter: TodoListPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter.attach(view: self)
        configureView()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
    }
    
    private func configureView() {
        title = "Todos"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func refreshTriggered() {
        presenter.didPullToRefresh()
    }
    
    private var isFiltering: Bool {
        let searchBarIsEmpty = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private func applyFilter(with text: String?) {
        let trimmed = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { item in
                item.title.range(of: trimmed, options: .caseInsensitive) != nil ||
                item.subtitle.range(of: trimmed, options: .caseInsensitive) != nil
            }
        }
        tableView.reloadData()
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = filteredItems[indexPath.row]
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = item.title
        configuration.secondaryText = item.subtitle
        cell.contentConfiguration = configuration
        return cell
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isFiltering else { return }
        presenter.didReachItem(at: indexPath.row)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredItems[indexPath.row]
        presenter.didSelectTodo(with: item.id)
    }
}

extension TodoListViewController: TodoListView {
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
                if tableView.contentOffset.y == 0 {
                    tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
                }
            }
        } else if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setFooterLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showTodos(_ viewModels: [TodoListItemViewModel], reset: Bool) {
        if reset {
            allItems = viewModels
        } else {
            allItems.append(contentsOf: viewModels)
        }
        applyFilter(with: searchController.searchBar.text)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showTodoDetails(_ viewModel: TodoDetailsViewModel) {
        let detailsViewController = TodoDetailsViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter(with: searchController.searchBar.text)
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        applyFilter(with: nil)
    }
}

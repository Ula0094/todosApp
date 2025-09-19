//
//  TodoListViewController.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import UIKit

final class TodoListViewController: UIViewController {
    private let presenter: TodoListPresenting
    private var items: [TodoListItemViewModel] = []
    
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
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = item.title
        configuration.secondaryText = item.subtitle
        cell.contentConfiguration = configuration
        return cell
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.didReachItem(at: indexPath.row)
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
            items = viewModels
        } else {
            items.append(contentsOf: viewModels)
        }
        tableView.reloadData()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

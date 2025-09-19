//
//  TodoDetailsViewController.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 19/09/25.
//

import UIKit

final class TodoDetailsViewController: UIViewController {
    private let viewModel: TodoDetailsViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(viewModel: TodoDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.navigationTitle
        view.backgroundColor = .systemBackground
        configureLayout()
        populateContent()
    }
    
    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateContent() {
        viewModel.items.forEach { item in
            let container = UIStackView()
            container.axis = .vertical
            container.spacing = 4
            
            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
            titleLabel.textColor = .secondaryLabel
            titleLabel.text = item.title
            
            let valueLabel = UILabel()
            valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
            valueLabel.textColor = .label
            valueLabel.numberOfLines = 0
            valueLabel.text = item.value
            
            container.addArrangedSubview(titleLabel)
            container.addArrangedSubview(valueLabel)
            stackView.addArrangedSubview(container)
        }
    }
}

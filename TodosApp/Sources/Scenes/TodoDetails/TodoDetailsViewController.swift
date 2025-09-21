//
//  TodoDetailsViewController.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 19/09/25.
//

import UIKit
import Stevia

final class TodoDetailsViewController: UIViewController {
    private let viewModel: TodoDetailsViewModel
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentView = UIView()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
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
        view.subviews(scrollView)
        scrollView.subviews(contentView)
        contentView.subviews(stackView)
        
        scrollView.fillHorizontally()
        scrollView.Top == view.safeAreaLayoutGuide.Top
        scrollView.Bottom == view.safeAreaLayoutGuide.Bottom
        
        contentView.fillHorizontally()
        contentView.Top == scrollView.Top
        contentView.Bottom == scrollView.Bottom
        contentView.Width == scrollView.Width
        
        stackView.Left == contentView.Left + 16
        stackView.Right == contentView.Right - 16
        stackView.Top == contentView.Top + 20
        stackView.Bottom == contentView.Bottom - 20
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

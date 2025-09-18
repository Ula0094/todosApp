//
//  PaginationState.swift
//  TodosApp
//
//  Created by Ulugbek Mukhsinovich on 18/09/25.
//

import Foundation

struct PaginationState {
    private(set) var currentPage: Int = 0
    private(set) var isLoading: Bool = false
    private(set) var hasMore: Bool = true
    
    mutating func reset() {
        currentPage = 0
        isLoading = false
        hasMore = true
    }
    
    mutating func startLoadingNextPage() -> Int? {
        guard !isLoading, hasMore else { return nil }
        isLoading = true
        return currentPage + 1
    }
    
    mutating func completeLoading(with page: PaginatedTodos) {
        currentPage = page.currentPage
        hasMore = page.hasMore
        isLoading = false
    }
    
    mutating func completeLoadingWithError() {
        isLoading = false
    }
}

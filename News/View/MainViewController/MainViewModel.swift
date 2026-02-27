//
//  MainViewModel.swift
//  News
//
//  Created by Anton Loginov on 24.02.2026.
//
import Combine

protocol MainViewModelProtocol {
    var articlesPublisher: AnyPublisher<[Article], Never> { get }
    
    func updateData(page: Int)
    
    func getArticles() -> [Article]
}

class MainViewModel: MainViewModelProtocol {
    
    private let networkManager: NetworkManagerProtocol
    @Published private(set) var articles: [Article] = []
    
    var articlesPublisher: AnyPublisher<[Article], Never> {
        $articles.eraseToAnyPublisher()
    }
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        updateData()
    }
    
    func updateData(page: Int = 1) {
        
        Task {
            do {
                let response = try await networkManager.getTopHeadlines(pageSize: 10, page: page)
                if let articles = response.articles {
                    self.articles.append(contentsOf: articles)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getArticles() -> [Article] {
        articles
    }
}

//func updateData(page: Int = 1) {
//    networkService.getTopHeadlines(pageSize: 10, page: page) { response in
//    
//        let startIndex = self.articles.count
//        
//        if let articles = response.articles {
//            self.articles.append(contentsOf: articles)
//        }
//        
//        self.tableView.insertRows(
//            at: (startIndex..<self.articles.count).map { IndexPath(row: $0, section: 0)},
//            with: .automatic
//        )
//    }
//}

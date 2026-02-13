//
//  ViewController.swift
//  News
//
//  Created by Anton Loginov on 07.01.2026.
//

import UIKit

class ViewController: UIViewController {

    private let networkService = NetworkManager()
    
    private var articles: [Article] = []
    
    private lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.register(CellView.self, forCellReuseIdentifier: CellView.reuseId)
        $0.separatorStyle = .none
        $0.prefetchDataSource = self
        return $0
    }(UITableView(frame: view.frame, style: .grouped))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        updateData()
    }
    
    func updateData(page: Int = 1) {
        networkService.getTopHeadlines(pageSize: 10, page: page) { response in
        
            let startIndex = self.articles.count
            
            if let articles = response.articles {
                self.articles.append(contentsOf: articles)
            }
            
            self.tableView.insertRows(
                at: (startIndex..<self.articles.count).map { IndexPath(row: $0, section: 0)},
                with: .automatic
            )
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row == articles.count - 1 }) {
            updateData(page: articles.count / 10 + 2)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellView.reuseId, for: indexPath) as? CellView
        cell?.setupCell(article: articles[indexPath.row])
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
}

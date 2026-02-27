//
//  ViewController.swift
//  News
//
//  Created by Anton Loginov on 07.01.2026.
//

import UIKit
import Combine

class ViewController: UIViewController {
        
    private let mainViewModel: MainViewModelProtocol
    private var bag: Set<AnyCancellable> = []
    
    init(mainViewModel: MainViewModelProtocol) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        bind()
    }
    
    func bind() {
        mainViewModel.articlesPublisher
            .receive(on: DispatchQueue.main)
            .scan(([], [])) { previous, new in
                return (previous.1, new)
            }
            .sink(receiveValue: { [weak self] (pairOfArticles) in
                let countOfPrevious = pairOfArticles.0.count
                let countOfCurrent = pairOfArticles.1.count
                
                self?.tableView.insertRows(
                    at: (countOfPrevious..<countOfCurrent).map { IndexPath(row: $0, section: 0)},
                    with: .automatic
                )
            })
            .store(in: &bag)
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row == mainViewModel.getArticles().count - 1 }) {
            mainViewModel.updateData(page: mainViewModel.getArticles().count / 10 + 2)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mainViewModel.getArticles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellView.reuseId, for: indexPath) as? CellView
        cell?.setupCell(article: mainViewModel.getArticles()[indexPath.row])
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
}

//
//  CellView.swift
//  News
//
//  Created by Anton Loginov on 27.01.2026.
//

import UIKit

class CellView: UITableViewCell {
    
    static let reuseId = "CellViewID"
    
    private var downloadTask: Task<Void, Never>?
    
    private var cellView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .cellBG
        $0.layer.cornerRadius = 30
        return $0
    }(UIView())
    
    private var cellsImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
        $0.heightAnchor.constraint(equalToConstant: 240).isActive = true
        return $0
    }(UIImageView())
    
    private lazy var labelHeader = createLabel(fontSize: 24, weight: .bold, numberOfLines: 2)
    
    private lazy var labelDescription = createLabel(fontSize: 18, numberOfLines: 5)
    
    private func createLabel(fontSize: CGFloat = 14, weight: UIFont.Weight = .regular, numberOfLines: Int = 0) -> UILabel {
        {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: fontSize, weight: weight)
            $0.numberOfLines = numberOfLines
            $0.textAlignment = .natural
            return $0
        }(UILabel())
    }
    
    func setupCell(article: Article) {
            
        labelHeader.text = article.title
        labelDescription.text = article.description
        
        guard let urlToImage = article.urlToImage, let url = URL(string: urlToImage) else { return }
        
        downloadTask = Task{ await cellsImageView.load(url: url) }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellView)
        cellView.addSubview(cellsImageView)
        cellView.addSubview(labelHeader)
        cellView.addSubview(labelDescription)
        
        setupConstrainsts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrainsts() {
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            cellsImageView.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 16),
            cellsImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            cellsImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16),
            
            labelHeader.topAnchor.constraint(equalTo: cellsImageView.bottomAnchor, constant: 8),
            labelHeader.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            labelHeader.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16),
            
            labelDescription.topAnchor.constraint(equalTo: labelHeader.bottomAnchor, constant: 8),
            labelDescription.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            labelDescription.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16),
            labelDescription.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -16)
            
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        cellsImageView.image = nil
        labelDescription.text = nil
        labelHeader.text = nil
    }
    
}

extension UIImageView {
    
    @MainActor
    func load(url: URL) async {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
        if Task.isCancelled { return }
        guard let image = UIImage(data: data) else { return }
        self.image = image
    }
}

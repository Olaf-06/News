//
//  Responce.swift
//  News
//
//  Created by Anton Loginov on 15.01.2026.
//
struct Response: Decodable {
    let status: APIStatus
    let articles: [Article]?
    let message: String?
}

struct Article: Decodable {
    let title: String?
    let description: String?
    let urlToImage: String?
    let content: String?
    let publishedAt: String?
    let source: Source?
}

struct Source: Decodable {
    let name: String?
}

enum APIStatus: String, Decodable {
    case ok
    case error
}

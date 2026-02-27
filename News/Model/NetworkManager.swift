//
//  NetworkManager.swift
//  News
//
//  Created by Anton Loginov on 15.01.2026.
//
import Foundation

protocol NetworkManagerProtocol {
    func getTopHeadlines(pageSize: Int, page: Int) async throws -> Response
}

class NetworkManager : NetworkManagerProtocol {
    let url = "https://newsapi.org"
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    let path = "/v2/top-headlines"
    
    func getTopHeadlines(pageSize: Int, page: Int) async throws -> Response {
        
        guard apiKey != nil else { throw URLError(.badURL) }
        
        var urlComponents = URLComponents(string: "\(url)\(path)")
        urlComponents?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "q", value: "ru"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
     
        guard let url = urlComponents?.url else { return Response(status: .error, articles: nil, message: "Invalid URL") }
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(Response.self, from: data)
    }
}


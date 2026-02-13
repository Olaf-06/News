//
//  NetworkManager.swift
//  News
//
//  Created by Anton Loginov on 15.01.2026.
//
import Foundation

class NetworkManager {
    let url = "https://newsapi.org"
    let apiKey = "099efdbdf1544a39b40d784565e17358"
    let path = "/v2/top-headlines"
    
    func getTopHeadlines(pageSize: Int, page: Int, completion: @escaping (Response) -> Void) {
        var urlComponents = URLComponents(string: "\(url)\(path)")
        urlComponents?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "q", value: "ru"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
     
        guard let url = urlComponents?.url else { return }
        
        print("\(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data else { return }
                                                
            Task { @MainActor in
                do {
                    let result: Response = try JSONDecoder().decode(Response.self, from: data)
                    
                    if result.status == .error {
                        print("Error: \(result.message ?? "Unknown error")")
                        return
                    } else if result.status == .ok {
                        completion(result)
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}


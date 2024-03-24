//
//  NewsAPI.swift
//  NewsAPI-naser
//
//  Created by Naser on 20/03/2024.
//

import Foundation
import Combine

struct NewsAPI {
    static let apiKey = "7ab0cbf5863b45a1b57048b8e611f8e1"
    static let baseUrl = "https://newsapi.org/v2/top-headlines"
    
    static func fetchArticles() -> AnyPublisher<[Article], Error> {
        guard let url = URL(string: "\(baseUrl)?country=us&apiKey=\(apiKey)") else {
            let error = URLError(.badURL)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .map { $0.articles }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
    }
}



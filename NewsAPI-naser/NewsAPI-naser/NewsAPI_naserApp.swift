//
//  NewsAPI_naserApp.swift
//  NewsAPI-naser
//
//  Created by Naser on 20/03/2024.
//

import SwiftUI
import WebKit

// News Model
struct News: Identifiable, Decodable {
    var id: String { url }
    let title: String
    let url: String
    let urlToImage: String?
}

// News List Decodable to match the API response structure
struct NewsList: Decodable {
    let articles: [News]
}

// News Service for fetching news
class NewsService {
    func getNews(completion: @escaping ([News]?) -> ()) {
        // Your API key is included in the URL
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=ce55790118874ceaad43e3a0fc91280d") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let newsList = try? JSONDecoder().decode(NewsList.self, from: data)
            DispatchQueue.main.async {
                completion(newsList?.articles)
            }
        }.resume()
    }
    
    func loadImage(url: String, completion: @escaping (Data?) -> ()) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}

// SwiftUI View for displaying news details
struct NewsDetailView: View {
    let news: News

    var body: some View {
        WebView(url: URL(string: news.url)!)
            .navigationTitle(news.title)
    }
}

// SwiftUI View for displaying a list of news
struct ContentView: View {
    @State private var newsList: [News] = []
    @State private var imageCache: [String: Data] = [:]
    
    var body: some View {
        NavigationView {
            List(newsList) { news in
                NavigationLink(destination: NewsDetailView(news: news)) {
                    HStack {
                        if let imageData = imageCache[news.urlToImage ?? ""] {
                            Image(uiImage: UIImage(data: imageData)!).resizable().frame(width: 60, height: 60).cornerRadius(8)
                        } else {
                            Image(systemName: "photo").resizable().frame(width: 100, height: 10).cornerRadius(8)
                                .onAppear {
                                    loadNewsImage(news: news)
                                }
                        }
                        VStack(alignment: .leading) {
                            Text(news.title)
                                .font(.headline)
                                .foregroundColor(Color.black)
                                .lineLimit(2)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("NEWS")
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding(.vertical, 0)
            .onAppear {
                NewsService().getNews { news in
                    self.newsList = news ?? []
                }
            }
        }
        .background(Color.gray.opacity(100))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func loadNewsImage(news: News) {
        guard let url = news.urlToImage else { return }
        
        NewsService().loadImage(url: url) { data in
            if let data = data {
                DispatchQueue.main.async {
                    imageCache[news.urlToImage ?? ""] = data
                }
            }
        }
    }
}

// SwiftUI WebView for displaying web content
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

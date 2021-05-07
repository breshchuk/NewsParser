//
//  NewsFromContextualWebSearch.swift
//  NewsParser
//
//  Created by Harbros61 on 6.05.21.
//

import Foundation

class NewsFromContextualWebSearch: Decodable, NewsProtocol {
    init(title: String, newsURL: String, briefExplanation: String, tags: [String] = [String](), language: String, date: String, provider: [String : String], body: String) {
        self.title = title
        self.newsURL = newsURL
        self.briefExplanation = briefExplanation
        self.tags = tags
        self.language = language
        self.date = date
        self.provider = provider
        self.body = body
    }
    
    func initAuthorsAndText() {
        text = body.components(separatedBy: "\n")
        author = [provider["name"] ?? ""]
    }
    
    
    var title: String
    var newsURL: String
    var briefExplanation: String
    var text = [String]()
    var tags = [String]()
    var language: String
    var date: String
    var provider: [String: String]
    var author = [String]()
    var body: String
    
    enum CodingKeys: String, CodingKey {
        case newsURL = "url"
        case title = "title"
        case language = "language"
        case date = "datePublished"
        case briefExplanation = "description"
        case provider
        case body
    }
}

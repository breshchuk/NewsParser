//
//  News.swift
//  News
//
//  Created by dimam on 10.03.21.
//

import Foundation
import Firebase

struct News: NewsProtocol {
    
    let newsURL : String
    let title : String
    var titleImageURL : String?
    var textUnderTitleImage : String?
    let briefExplanation : String
    let author: [String]
    let language: String
    let date: String
    let text: [String]
    var imagesURL : [String]?
    let tags: [String]
    
    init(newsURL: String, title: String, briefExplanation: String ,titleImageURL: String, textUnderTitleImage: String, author: [String], language: String, date: String, text: [String], imagesURL: [String], tags: [String]) {
        self.init(newsURL: newsURL, title: title,briefExplanation: briefExplanation, author: author, language: language, date: date, text: text, tags: tags)
        self.titleImageURL = titleImageURL
        self.textUnderTitleImage = textUnderTitleImage
        self.imagesURL = imagesURL
    }
    
    init(newsURL: String, title: String, briefExplanation: String , titleImageURL: String, textUnderTitleImage: String, author: [String], language: String, date: String, text: [String], tags: [String]) {
        self.init(newsURL: newsURL, title: title,briefExplanation: briefExplanation, author: author, language: language, date: date, text: text, tags: tags)
        self.textUnderTitleImage = textUnderTitleImage
        self.titleImageURL = titleImageURL
    }
    
    init(newsURL: String, title: String,briefExplanation: String, author: [String], language: String, date: String, text: [String], tags: [String]) {
        self.newsURL = newsURL
        self.title = title
        self.briefExplanation = briefExplanation
        self.author = author
        self.language = language
        self.date = date
        self.text = text
        self.tags = tags
    }
}

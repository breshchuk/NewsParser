//
//  News.swift
//  News
//
//  Created by dimam on 10.03.21.
//

import Foundation
import Firebase

struct News {
    
    let newsHash : String
    let newsURL : String
    let title : String
    var titleImageURL : String? = nil
    var textUnderTitleImage : String? = nil
    let author: [String]
    let language: String
    let date: String
    let text: [String]
    var imagesURL : [String]? = nil
    let tags: [String]
    var ref: DatabaseReference?
    
    init(newsHash: String,newsURL: String, title: String,titleImageURL: String,textUnderTitleImage: String, author: [String], language: String, date: String, text: [String], imagesURL: [String], tags: [String]) {
        self.init(newsHash: newsHash, newsURL: newsURL, title: title, author: author, language: language, date: date, text: text, tags: tags)
        self.titleImageURL = titleImageURL
        self.textUnderTitleImage = textUnderTitleImage
        self.imagesURL = imagesURL
    }
    
    init(newsHash: String,newsURL: String, title: String,titleImageURL: String,textUnderTitleImage: String, author: [String], language: String, date: String, text: [String], tags: [String]) {
        self.init(newsHash: newsHash, newsURL: newsURL, title: title, author: author, language: language, date: date, text: text, tags: tags)
        self.textUnderTitleImage = textUnderTitleImage
        self.titleImageURL = titleImageURL
    }
    
    init(newsHash: String,newsURL: String, title: String, author: [String], language: String, date: String, text: [String], tags: [String]) {
        self.newsHash = newsHash
        self.newsURL = newsURL
        self.title = title
        self.author = author
        self.language = language
        self.date = date
        self.text = text
        self.tags = tags
    }
    
}

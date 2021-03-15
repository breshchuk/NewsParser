//
//  News.swift
//  News
//
//  Created by dimam on 10.03.21.
//

import Foundation
import Firebase

struct News {
    
    let newsURL : String
    let title : String
    let titleImageURL : String
    let author: [String]
    let language: String
    let date: String
    let text: [String]
    let imagesURL : [String]
    let tags: [String]
    var ref: DatabaseReference?
    
    init(newsID: String, title: String,titleImageURL: String, author: [String], language: String, date: String, text: [String], imagesURL: [String], tags: [String]) {
        self.newsURL = newsID
        self.title = title
        self.titleImageURL = titleImageURL
        self.author = author
        self.language = language
        self.date = date
        self.text = text
        self.imagesURL = imagesURL
        self.tags = tags
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        titleImageURL = snapshotValue["titleImageURL"] as! String
        newsURL = snapshotValue["newsURL"] as! String
        author = snapshotValue["author"] as! [String]
        language = snapshotValue["language"] as! String
        date = snapshotValue["date"] as! String
        text = snapshotValue["text"] as! [String]
        imagesURL = snapshotValue["imagesURL"] as! [String]
        tags = snapshotValue["tags"] as! [String]
        ref = snapshot.ref
    }
}

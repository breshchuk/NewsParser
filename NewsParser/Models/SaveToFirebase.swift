//
//  SaveToFirebase.swift
//  NewsParser
//
//  Created by dimam on 21.03.21.
//

import Foundation
import Firebase
import CryptoKit

class SaveToFirebase {
    
    var ref = Database.database().reference().child("news")
    
    func createMD5forNews(newsURL: String) -> String {
        let hash = Insecure.MD5.hash(data: newsURL.data(using: .utf8)!)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func saveNews(news: News) {
        let md5 = createMD5forNews(newsURL: news.newsURL)
        let newsRef = self.ref.child(md5)
        newsRef.setValue(news.convertToDict())
    }
}

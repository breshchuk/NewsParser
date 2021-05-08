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
    
    func saveNews(news: NewsProtocol) {
        let md5 = createMD5forNews(newsURL: news.newsURL)
        let newsRef = self.ref.child(md5)
        newsRef.setValue(convertToDict(news: news))
    }
    
    func convertToDict(news: NewsProtocol) -> Any {
        var mainReturn: [String: Any] = ["newsURL": news.newsURL, "title": news.title, "briefExplanation": news.briefExplanation ,"author": news.author, "language": news.language, "date": news.date, "text": news.text, "tags": news.tags]
        if let news = news as? News {
            if let imagesURL = news.imagesURL, !imagesURL.isEmpty, !imagesURL.first!.isEmpty {
                mainReturn["imageURL"] = imagesURL
            }
            if let textUnderTitleImage = news.textUnderTitleImage , !textUnderTitleImage.isEmpty {
                mainReturn["textUnderTitleImage"] = textUnderTitleImage
            }
            if let titleImageURL = news.titleImageURL, !titleImageURL.isEmpty {
                mainReturn["titleImageURL"] = titleImageURL
            }
        } else if let news = news as? NewsFromContextualWebSearch {
            
        }
        return mainReturn
    }
}

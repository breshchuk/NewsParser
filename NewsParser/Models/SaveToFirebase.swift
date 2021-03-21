//
//  SaveToFirebase.swift
//  NewsParser
//
//  Created by dimam on 21.03.21.
//

import Foundation
import Firebase

class SaveToFirebase {
    var ref : DatabaseReference!
    var latestNewsURL : String!
    
    init() {
        ref = Database.database().reference().child("news")
        ref.observe(.value) { [weak self] (snapshot) in
            for item in snapshot.children {
                let snapNews = item as! DataSnapshot
                let value = snapNews.value as! [String: AnyObject]
                self?.latestNewsURL = value["newsURL"] as? String
                break
            }
            
        }
    }
    
    func saveNews(news: News) {
        let newsRef = self.ref.childByAutoId()
        newsRef.setValue(news.convertToDict())
    }
    
    
    deinit {
        ref.removeAllObservers()
    }
}

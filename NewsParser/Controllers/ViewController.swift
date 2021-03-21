//
//  ViewController.swift
//  NewsParser
//
//  Created by dimam on 15.03.21.
//

import Cocoa
import SwiftSoup
import Firebase

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        let parser = ParserFromNY()
        var newsArray = [News]()
        
        //MARK: - Parse data
        do {
        newsArray = try parser.getNews()
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print(error.localizedDescription)
        }
        
        //MARK: - Check user
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: "breschuk1@gmail.com", password: "Test123")
            
        }
        //MARK: - Save data
        let saver = SaveToFirebase()
        
        for item in newsArray {
            saver.saveNews(news: item)
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


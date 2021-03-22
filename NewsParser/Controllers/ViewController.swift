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
    
    var newsArray = [News]()
    var parsers: [NewsParserProtocol] = [ParserFromNY()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        //MARK: - Check user
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: "breschuk1@gmail.com", password: "Test123")
        }
        
        let timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateNews), userInfo: nil, repeats: true)
        
        timer.fire()
    }
    
    
    @objc private func updateNews() {
        
        //MARK: - Parse data
        do {
            for parser in parsers {
                newsArray.append(contentsOf: try parser.getNews())
            }
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print(error.localizedDescription)
        }
        
        
        //MARK: - Save data
        let saver = SaveToFirebase()
        
        for item in newsArray {
            saver.saveNews(news: item)
        }
        
        newsArray.removeAll()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


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
    let parser = ParserFromNY()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
        try parser.getLinks()
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


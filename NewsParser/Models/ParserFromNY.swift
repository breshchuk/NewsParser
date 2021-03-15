//
//  Parser.swift
//  News
//
//  Created by dimam on 10.03.21.
//

import Foundation
import SwiftSoup

class ParserFromNY {
    
    private var news = [News]()
    private let strNewsURL = "https://www.nytimes.com/section/world"
    
    private var getURL: String {
        let splitURL = strNewsURL.split(separator: "/")
        return String(splitURL[1])
    }
    
    private func getURLTreeFromStr() -> String {
        guard let url = URL(string: strNewsURL) else  { return "Error" }
        let contents = try! String(contentsOf: url)
        return contents
    }
    
    private func parseToHTML(html: String) -> Document {
        do {
        let doc: Document = try SwiftSoup.parse(html)
        return doc
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
            return Document("")
        } catch {
            print("error")
            return Document("")
        }
        
    }
    
    func getLinks() throws {
        let doc : Document = parseToHTML(html: getURLTreeFromStr())
        let latestNews = try doc.select("body > #app > div:nth-child(2) #site-content > #collection-world > div.css-psuupz.e1o5byef0 > div > #stream-panel > div.css-13mho3u > ol").first()
//        let body = try doc.select("body").first()!
//        let firstDiv = try body.select("div").first()!
//        let secondDiv = try firstDiv.select("div[aria-hidden]").first()!
//        let section = try secondDiv.select("section#collection-world").first()!
//        let thirdDiv = try section.select("div.css-psuupz.e1o5byef0").first()!
//        let fouthDiv = try thirdDiv.select("div.css-15cbhtu").first()!
//        let secondSection = try fouthDiv.select("section#stream-panel").first()!
//        let fifthDiv = try secondSection.select("div.css-13mho3u").first()!
//        let ol = try fifthDiv.select("ol[aria-live]").first()!
        
        if let ln = latestNews {
        for element : Element in ln.children() {
            if element.hasClass("css-ye6x8s") {
              try getNewsTitleData(element: element)
            }
        }
        } else {
            
        }
    }
    
   private func getAuthors(authors: String) -> [String] {
        var returnArray = [String]()
        var tempStr = String()
        if authors.contains(",") {
            let splitAuthorsArray = authors.split(separator: ",")
            for (index,author) in splitAuthorsArray.enumerated() {
                if index == splitAuthorsArray.count - 1 {
                    var splitAuthor = author.split(separator: " ")
                    splitAuthor.removeFirst()
                    for item in splitAuthor {
                        tempStr += (item + " ")
                    }
                    tempStr.removeLast()
                    returnArray.append(tempStr)
                    break
                }
                returnArray.append(String(author))
            }
        } else {
            let splitAuthorArray = authors.split(separator: " ")
            for (index,item) in splitAuthorArray.enumerated() {
                if item == "and" {
                    tempStr.removeLast()
                    returnArray.append(tempStr)
                    tempStr = ""
                    continue
                }
                tempStr += (item + " ")
                if index == splitAuthorArray.count - 1 {
                    tempStr.removeLast()
                    returnArray.append(tempStr)
                }
            }
        }
        return returnArray
    }
    
    private func getNewsTitleData(element: Element) throws {
//        let firstDiv = try element.select("div.css-1cp3ece").first()!
//        let secDiv = try firstDiv.select("div.css-1l4spti").first()!
//        let dateDiv = try firstDiv.select("div.css-1lc2l26.e1xfvim33").first()!
        
        let a = try element.select("div > div.css-1l4spti > a")
        
        let newsTitleAndAuthorAndText = try a.text()
        //MARK: - Get newsURL
        let newsURL = try self.getURL + a.attr("href")
        
        
        //MARK: - Get title
        let title = try a.select("h2").text()
        
        
        //MARK: - Get date
        let date = try a.select("div.css-1lc2l26.e1xfvim33 > span").text()
        
        
        //MARK: - Get authors
        let authors = try a.select("div.css-1nqbnmb.ea5icrr0 > p").first()!
        var authorsArray = [String]()
        for author in authors.children() {
            try authorsArray = getAuthors(authors: author.text())
        }
        //MARK: - Get brief explanation
        let briefExplanation = try a.select("p").text()
        
        
        //MARK: - Get title image
        let titleImage = try a.select("div.css-79elbk > figure > div > img").first()!.attr("src")
        
        
        //MARK: - Get title image
        
        
        print(titleImage)
        
        
        
    }
    
    
    private func getNewsMainData() {
        
    }
    
}

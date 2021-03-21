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
    private let strNewsWorldURL = "https://www.nytimes.com/section/world"
    
    private var mainURL = "https://www.nytimes.com"
    
    private func getURLTreeFromStr(strURL: String) -> String {
        guard let url = URL(string: strURL) else  { return "Error" }
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
        let doc : Document = parseToHTML(html: getURLTreeFromStr(strURL: strNewsWorldURL))
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
        if let video = try a.select("h3 > span.css-1a54gqt").first() { return }
        
        //MARK: - Get newsURL
        let newsURL = try self.mainURL + a.attr("href")
        
        
        //MARK: - Get tag
        let tag = try String(a.attr("href").split(separator: "/").first!)
        
        
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
        
        
        //MARK: - Get main news data
       let mainNewsData = try getNewsMainData(newsURL: newsURL)
        
        //print(titleImage)
        
        
        
    }
    
    private func splitTextUnderImage(text: String) -> String {
        let splitText = text.split(separator: ".")
        if let text = splitText.first, let source = splitText.last {
            if text.contains("Credit") {
                return String(source)
            } else {
                return String(text + ". " + source)
            }
        }
        return String()
    }
     
    //MARK: - Get main news text function
    private func getMainText(textDiv: Element) throws -> [String] {
        var textArray = [String]()
        for textElement in textDiv.children() {
            if textElement.hasClass("css-axufdj") {
                textArray.append(try textElement.text())
            } else if textElement.hasClass("css-1aoo5yy") {
                try textArray.append("Bold-> " + textElement.text())
            }
        }
        return textArray
    }
   
    //MARK: - Get image
    private func getImage(imageDiv: Element) throws -> String {
        if let imageURL = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > div > picture > img").first()?.attr("src") {
            return imageURL
        } else if let imageURL = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > div > div > div > picture > img").first()?.attr("src") {
            return imageURL
        }
        return String()
    }
    
    //MARK: - Get text under image
    private func getTextUnderImage(imageDiv: Element) throws -> String {
        guard var textUnderImage = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-cnj6d5.e1z0qqy90").first()?.text() else { return String() }
        textUnderImage = splitTextUnderImage(text: textUnderImage)
        return textUnderImage
    }
    
    
    private func getNewsMainData(newsURL: String) throws -> (date: String,textArray: [String],textUnderTitleImage: String,imagesArray: [String]) {
        let doc : Document = parseToHTML(html: getURLTreeFromStr(strURL: newsURL))
        var textArray = [String]()
        var imagesArray = [String]()
        
        let mainArticle = try doc.select("body #app > div > div > div:nth-child(2) > #site-content > div > #story").first()!
        
        //MARK: - Get text under title image and date
        var textUnderTitleImage = String()
        var date = String()
        if let header = try mainArticle.select("header").first(), let div = try header.select("div.css-79elbk").first() {
            textUnderTitleImage = try div.select("div.css-1a48zt4.ehw59r15 > figure > figcaption").text()
            date = try header.select("div.css-18e8msd > ul > li > time").first()!.text()
            
        } else if let headerDiv = try mainArticle.select("div.css-1422fwo").first() {
            textUnderTitleImage = try headerDiv.select("div.css-79elbk > div.css-1a48zt4.ehw59r15 > figure > figcaption").text()
            date = try headerDiv.select("div.css-pscyww > div > span > time > div").text()
            
        } else if let secondHeaderDiv = try mainArticle.select("div.css-79elbk").first() {
            textUnderTitleImage = try secondHeaderDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption").text()
            date = try mainArticle.select("#story > header > div.css-18e8msd > ul > li > time").text()
        } else {
        
        }
        textUnderTitleImage = splitTextUnderImage(text: textUnderTitleImage)
        
        //MARK: - Get main text
        let articleBody = try mainArticle.select("section").first()!
        for element in articleBody.children() {
            if let textDiv = try element.select("div.css-1fanzo5.StoryBodyCompanionColumn > div").first() {
                textArray.append(contentsOf: try getMainText(textDiv: textDiv))
            } else if let imageDiv = try element.select("div.css-79elbk").first() {
                imagesArray.append(try getImage(imageDiv: imageDiv))
                try textArray.append("Image->\(imagesArray.count - 1) " + getTextUnderImage(imageDiv: imageDiv))
            }
        }
        
        return (date,textArray,textUnderTitleImage,imagesArray)
        
    }
    
}

//
//  Parser.swift
//  News
//
//  Created by dimam on 10.03.21.
//

import Foundation
import SwiftSoup

class ParserFromNY: NewsParserProtocol {
    
    
    private var newsArray = [News]()
    private let strNewsWorldURL = "https://www.nytimes.com/section/world"
    
    private var mainURL = "https://www.nytimes.com"
    
    private func getURLTreeFromStr(strURL: String) throws -> String {
        guard let url = URL(string: strURL) else  { throw Exception.Error(type: ExceptionType.MalformedURLException, Message: "Can't get URL") }
        guard let contents = try? String(contentsOf: url) else { throw Exception.Error(type: ExceptionType.MalformedURLException, Message: "Can't get URL contents") }
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
    
    func getNews() throws -> [News] {
        let doc : Document = try parseToHTML(html: getURLTreeFromStr(strURL: strNewsWorldURL))
       if let latestNews = try doc.select("body > #app > div:nth-child(2) #site-content > #collection-world > div.css-psuupz.e1o5byef0 > div > #stream-panel > div.css-13mho3u > ol").first() {
        for element : Element in latestNews.children() {
            if element.hasClass("css-ye6x8s") {
              try getAllNewsData(element: element)
            }
        }
        } else {
            
        }
        return newsArray
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
    
    private func getAllNewsData(element: Element) throws {
        
        let a = try element.select("div > div.css-1l4spti > a")
        // Check if post is video
        if let _ = try a.select("h3 > span.css-1a54gqt").first() { return }
        
        //MARK: - Get newsURL
        let newsURL = try self.mainURL + a.attr("href")
        
        
        //MARK: - Get tag
        let tags = try [String(a.attr("href").split(separator: "/")[3])]
        
        
        //MARK: - NEEDS TO REWRITE
        if tags.contains("briefing") { return }
        
        //MARK: - Get title
        let title = try a.select("h2").text()
        
    
        //MARK: - Get authors
        guard let authors = try a.select("div.css-1nqbnmb.ea5icrr0 > p").first() else { throw Exception.Error(type: ExceptionType.SelectorParseException, Message: "Can't parse authors")}
        var authorsArray = [String]()
        for author in authors.children() {
            try authorsArray = getAuthors(authors: author.text())
        }
        //MARK: - Get brief explanation
        let briefExplanation = try a.select("p.css-1echdzn.e1xfvim31").text()
        
        
        //MARK: - Get title image
        guard let titleImageURL = try a.select("div.css-79elbk > figure > div > img").first()?.attr("src") else {throw Exception.Error(type: ExceptionType.SelectorParseException, Message: "Can't parse titleImageURL")}
        
        
        //MARK: - Get main news data(tuple)
       let mainNewsData = try getNewsMainData(newsURL: newsURL)
        
        
        //MARK: - Get date
        let date = mainNewsData.date
        
        
        //MARK: - Get text under title image
        let textUnderTitleImage = mainNewsData.textUnderTitleImage
        
        
        //MARK: - Get main text
        let text = mainNewsData.textArray
        
        
        //MARK: - Get imagesURL
        let imagesURL = mainNewsData.imagesURLArray
        
        let language = "en"
        
        let news = News(newsURL: newsURL, title: title,briefExplanation: briefExplanation, titleImageURL: titleImageURL, textUnderTitleImage: textUnderTitleImage, author: authorsArray, language: language, date: date, text: text, imagesURL: imagesURL, tags: tags)
        newsArray.append(news)
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
        if let textUnderImage = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-16f3y1r.e13ogyst0").first()?.text() {
            guard let textUnderImageAuthor = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-cnj6d5.e1z0qqy90 > span:nth-child(2)").first()?.text() else { return textUnderImage }
            return textUnderImage + " " + textUnderImageAuthor
        } else if let textUnderImage = try imageDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span > span:nth-child(2)").first()?.text() {
            return textUnderImage
        }
        return String()
    }
    
    
    private func getNewsMainData(newsURL: String) throws -> (date: String,textArray: [String],textUnderTitleImage: String,imagesURLArray: [String]) {
        let doc : Document = try parseToHTML(html: getURLTreeFromStr(strURL: newsURL))
        var textArray = [String]()
        var imagesURLArray = [String]()
        
        guard let mainArticle = try doc.select("body #app > div > div > div:nth-child(2) > #site-content > div > #story").first() else {throw Exception.Error(type: ExceptionType.SelectorParseException, Message: "Can't parse main article")}

        //MARK: - Get text under title image and date
        var textUnderTitleImage = String()
        var date = String()
        if let header = try mainArticle.select("header").first(), let div = try header.select("div.css-79elbk").first() {
            textUnderTitleImage = try div.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-16f3y1r.e13ogyst0").text() + " " + div.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-cnj6d5.e1z0qqy90 > span:nth-child(2)").text()
            if let _date = try header.select("div.css-18e8msd > ul > li > time").first()?.attr("datetime") {
                date = _date
            } else if let _date = try header.select("div.css-1lvorsa > time").first()?.attr("datetime") {
                date = _date
            }
            
        } else if let headerDiv = try mainArticle.select("div.css-1422fwo").first() {
            textUnderTitleImage = try headerDiv.select("div.css-79elbk > div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-16f3y1r.e13ogyst0").text() + " " + headerDiv.select("div.css-79elbk > div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-cnj6d5.e1z0qqy90 > span:nth-child(2)").text()
            date = try headerDiv.select("div.css-pscyww > div > span > time").attr("datetime")
            
        } else if let secondHeaderDiv = try mainArticle.select("div.css-79elbk").first() {
            textUnderTitleImage = try secondHeaderDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-16f3y1r.e13ogyst0").text() + " " + secondHeaderDiv.select("div.css-1a48zt4.ehw59r15 > figure > figcaption > span.css-cnj6d5.e1z0qqy90 > span:nth-child(2)").text()
            date = try mainArticle.select("#story > header > div.css-18e8msd > ul > li > time").attr("datetime")
        } else if let fullBleedHeaderContent = try mainArticle.select("#fullBleedHeaderContent").first() {
            textUnderTitleImage = try fullBleedHeaderContent.select("div.css-yi0xdk.e1gnum310 > p > span.css-cnj6d5.e1z0qqy90 > span:nth-child(2) > span").text()
            date = try fullBleedHeaderContent.select("div.css-1wx1auc.e1gnum311 > div.css-18e8msd > ul > li > time").attr("datetime")
        }
        
        //MARK: - Get main text
        guard let articleBody = try mainArticle.select("[name=articleBody]").first() else {throw Exception.Error(type: ExceptionType.SelectorParseException, Message: "Can't parse articleBody")}
        for element in articleBody.children() {
            if let textDiv = try element.select("div.css-1fanzo5.StoryBodyCompanionColumn > div").first() {
                textArray.append(contentsOf: try getMainText(textDiv: textDiv))
            } else if let imageDiv = try element.select("div.css-79elbk").first() {
                imagesURLArray.append(try getImage(imageDiv: imageDiv))
                try textArray.append("Image->\(imagesURLArray.count - 1) " + getTextUnderImage(imageDiv: imageDiv))
            }
        }
        
        return (date,textArray,textUnderTitleImage,imagesURLArray)
        
    }
    
}

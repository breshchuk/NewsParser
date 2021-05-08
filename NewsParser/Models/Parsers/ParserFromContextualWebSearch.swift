//
//  ParserFromContextualWebSearch.swift
//  NewsParser
//
//  Created by dimam on 1.05.21.
//

import Foundation

class ParserFromContextualWebSearch: NewsParserProtocol {
    
    private let headers = [
        "x-rapidapi-key": "6ec37195abmshf37dbe9410e2c75p1cb6e5jsnb229f1e80064",
        "x-rapidapi-host": "contextualwebsearch-websearch-v1.p.rapidapi.com"
    ]
    
    private var requestURL = "https://contextualwebsearch-websearch-v1.p.rapidapi.com/api/search/TrendingNewsAPI?pageNumber=1&pageSize=10&withThumbnails=false&location=us"
    
    lazy private var request: NSMutableURLRequest = {
        let request = NSMutableURLRequest(
            url: NSURL(string: requestURL)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        return request
    }()
    
    func getNews(completionHandler: @escaping (_ result: Result<[NewsProtocol], ParserErrors>) -> Void )   {
        
        let session = URLSession.shared
        let dataTask = session.dataTask (with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                DispatchQueue.main.async {
                    completionHandler(.failure(.custom(errorStr: error.debugDescription)))
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...300).contains(httpResponse.statusCode) {
                
                guard let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.custom(errorStr: "Cannot parse to jsonObject")))
                    }
                    return
                }
                guard let jsonValues = try? JSONSerialization.data(
                    withJSONObject: jsonDict["value"],
                    options:[]
                ) else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.custom(errorStr: "Cannot parse to jsonObject")))
                    }
                    return
                }
                
                guard let newsArr = try? JSONDecoder().decode([NewsFromContextualWebSearch].self, from: jsonValues) else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(.custom(errorStr: "Cannot parse to jsonObject")))
                    }
                    return
                }
                newsArr.forEach {
                    $0.initAuthorsAndText()
                }
                DispatchQueue.main.async {
                    completionHandler(.success(newsArr))
                }
            }
        })
        
        dataTask.resume()
    }
    
    
}

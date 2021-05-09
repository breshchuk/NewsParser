//
//  FilterNewsJSON.swift
//  NewsParser
//
//  Created by Harbros61 on 8.05.21.
//

import Foundation

enum FilterError: Error {
    case dataToJson
}

enum FilterParametres {
    case everything(author: String, title: String, fromDate: String?, toDate: String?)
}

protocol FilterJSON {
    func filter(
        by filterParametres: [FilterParametres],
        jsonData: Data,
        completion: @escaping (Result<Data, FilterError>) -> Void
    )
}

class FilterNewsJSON: FilterJSON {
    
    var JSONDict = [String: Any]()
    
    func filter(
        by filterParametres: [FilterParametres],
        jsonData: Data,
        completion: @escaping (Result<Data, FilterError>) -> Void
    ) {
        guard
            let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            completion(.failure(.dataToJson))
            return
        }
        JSONDict = jsonDict
        var filteredJSON = [String: Any]()
        filterParametres.forEach {
            switch $0 {
            case .everything(let author, let title, let from, let to):
                filteredJSON = filterEverything(
                    author: author,
                    title: title,
                    from: from,
                    to: to
                )
            }
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: filteredJSON, options: []) else {
            return
        }
        completion(.success(jsonData))
    }
    
    
    private func filterByAuthor(authorName: String) -> [String: Any] {
        var filteredJSON = [String: Any]()
        self.JSONDict.forEach { key, value in
            guard let news = value as? [String: Any] else {
                return
            }
            if let authors = news["author"] as? [String] {
                authors.forEach {
                    if $0.contains(authorName) {
                        filteredJSON[key] = value
                    }
                }
            }
        }
        self.JSONDict = filteredJSON
        return filteredJSON
    }
    
    private func filterByTitle(title: String) -> [String: Any] {
        var filteredJSON = [String: Any]()
        self.JSONDict.forEach { key, value in
            guard let news = value as? [String: Any] else {
                return
            }
            if let titleFromJSON = news["title"] as? String {
                if titleFromJSON.contains(title) {
                    filteredJSON[key] = value
                }
            }
        }
        self.JSONDict = filteredJSON
        return filteredJSON
    }
    
    private func filterByDate(from: String,to: String) -> [String: Any] {
        var filteredJSON = [String: Any]()
        self.JSONDict.forEach { key, value in
            guard let news = value as? [String: Any] else {
                return
            }
            if let authors = news["title"] as? [String] {
                if authors.contains(from) {
                    filteredJSON[key] = value
                }
            }
        }
        self.JSONDict = filteredJSON
        return filteredJSON
    }
    
    private func filterEverything(author: String, title: String, from: String?, to: String?) -> [String: Any] {
        var filteredArray = [String: Any]()
        if !author.isEmpty {
            filteredArray = filterByAuthor(authorName: author)
        }
        if !title.isEmpty {
            filteredArray = filterByTitle(title: title)
        }
        return filteredArray
    }
    
}

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
    case author
    case title
    case date
    case everything
}

protocol FilterJSON {
    func filter(by filterParametres: [FilterParametres],jsonData: Data, completion: @escaping (Result<Data, FilterError>) -> Void )
}

class FilterNewsJSON: FilterJSON {
    
    func filter(
        by filterParametres: [FilterParametres],
        jsonData: Data,
        completion: @escaping (Result<Data, FilterError>) -> Void
    ) {
        var filteredJSON = [String: Any]()
        guard
            let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            completion(.failure(.dataToJson))
            return
        }
        jsonDict.forEach { key, value in
            guard let news = value as? [String: Any] else {
                return
            }
            if let authors = news["author"] as? [String] {
                if authors.contains("Remy Tumin") {
                    filteredJSON[key] = value
                }
            }
        }
        print(filteredJSON.keys)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: filteredJSON, options: []) else {
            return
        }
        completion(.success(jsonData))
    }
    
}

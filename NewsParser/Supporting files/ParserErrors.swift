//
//  ParserErrors.swift
//  NewsParser
//
//  Created by dimam on 2.05.21.
//

import Foundation

enum ParserErrors: Error {
    case doc
    case latestNews
    case parse
    case custom(errorStr: String)
}

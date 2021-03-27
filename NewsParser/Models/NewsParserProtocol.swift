//
//  NewsParserProtocol.swift
//  NewsParser
//
//  Created by dimam on 22.03.21.
//

import Foundation

protocol NewsParserProtocol {
    func getNews() throws -> [News]
}

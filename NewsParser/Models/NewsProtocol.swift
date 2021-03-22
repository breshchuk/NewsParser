//
//  NewsProtocol.swift
//  NewsParser
//
//  Created by dimam on 22.03.21.
//

import Foundation

protocol NewsProtocol {
    var title: String { get }
    var newsURL: String { get }
    var author: [String] { get }
    var briefExplanation: String { get }
    var date: String { get }
    var language: String { get }
    var text: [String] { get }
    var tags: [String] { get }
}

//
//  Symbol.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 21/06/2024.
//

import Foundation

struct Symbol: Decodable {
    let unicode: String
    let name: String
    let specificationNotation: String
    let category: String
    let prefix: String
    let position: String
    
    enum CodingKeys: String, CodingKey {
        case unicode = "Unicode"
        case name = "Name"
        case specificationNotation = "Specification Notation"
        case category = "Category"
        case prefix = "Prefix"
        case position = "Position"
    }
}

struct TermGroup: Decodable, Hashable {
    let type: String
    let section: String
    let terms: [Term]
}

struct Term: Decodable, Hashable {
    let name: String
    let meaning: String
    let symbols: [[String]]?
    let bpm: [Int]?
    let abbreviation: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case meaning = "meaning"
        case symbols = "symbols"
        case bpm = "bpm"
        case abbreviation = "abbreviation"
    }
}

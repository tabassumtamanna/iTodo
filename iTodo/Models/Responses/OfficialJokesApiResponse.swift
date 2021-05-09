//
//  OfficialJokesApiResponse.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 5/7/21.
//

import Foundation

struct OfficialJokesApiResponse: Codable {
    
    let id: Int
    let type: String
    let setup: String
    let punchline: String
    
}

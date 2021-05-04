//
//  TaskListResponse.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 5/3/21.
//

import Foundation

struct TaskListResponse: Codable {
    
    let kind: String
    let id: String
    let etag: String
    let title: String
    let updated: String
    let selfLink: String
    
}

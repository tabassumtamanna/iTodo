//
//  Task.swift
//  iTodo
//
//  Created by Tabassum Tamanna on 4/25/21.
//

import Foundation

// MARK: -  Task
struct Task: Codable {
    let taskTitle: String
    let status: String
    let taskCreated: String
    let taskCompleted: String
    let userId: String
    
}

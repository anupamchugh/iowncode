//
//  Models.swift
//  SwiftUIHNSentiments
//
//  Created by Anupam Chugh on 20/02/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import Foundation

struct StoryItem : Identifiable, Codable {
    let by: String
    let id: Int
    let kids: [Int]?
    let title: String?

    private enum CodingKeys: String, CodingKey {
            case by, id, kids, title
        }
}

struct CommentItem : Identifiable, Codable {
    
    let id: Int
    var text: String?
    var sentimentScore : String = ""

    private enum CodingKeys: String, CodingKey {
            case id, text
        }
}

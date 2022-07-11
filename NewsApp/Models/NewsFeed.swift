//
//  NewsFeed.swift
//  NewsApp
//
//  Created by Matheus Matsumoto on 08/07/22.
//

import Foundation

struct NewsFeed: Codable {
    
    var status: String?
    var totalResults: Int = 0
    var articles: [Article]?
    
}

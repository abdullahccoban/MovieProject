//
//  Movie.swift
//  MovieProject
//
//  Created by Abdullah Coban on 14.07.2021.
//

import Foundation

struct MovieList: Decodable {
    let results: [Movie]
    let page: Int
}

struct Movie: Decodable {
    
    let id: Int
    let title: String
    let overview: String
    let vote_count: Int
    let poster_path: String
    
    
}

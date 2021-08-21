//
//  MovieService.swift
//  MovieProject
//
//  Created by Abdullah Coban on 14.07.2021.
//

import Foundation

protocol MovieService {
    
    func getMovies() -> ()
    func getMovieById(id: Int) -> ()
    func searchMovie(query: String) -> ()
    
}

enum MovieError: Error, CustomNSError {
    
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}

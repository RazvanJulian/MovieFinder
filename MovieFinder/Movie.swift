//
//  Movie.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import Foundation
import UIKit

class Movie: NSObject {
    
    private(set)var averageVote: Double?
    private(set)var title: String?
    private(set)var overview: String?
    private(set)var posterImageURLMedium: URL?
    private(set)var posterImageURLHigh: URL?
    private(set)var posterImageURLLow: URL?
    private(set)var backdropImageURLMedium: URL?
    private(set)var backdropImageURLHigh: URL?
    private(set)var backdropImageURLLow: URL?
    private(set)var releaseYear: String?
    
    
    init(dictionary: NSDictionary) {
        
        let posterImagePath = dictionary["poster_path"] as? String
        let backdropImagePath = dictionary["backdrop_path"] as? String
        let title = dictionary["title"] as? String
        let overview = dictionary["overview"] as? String
        let releaseYear = (dictionary["release_date"] as? String)?.components(separatedBy: "-")[0]
        let averageVote = dictionary["vote_average"] as? Double
        
        self.title = title
        self.overview = overview
        self.releaseYear = releaseYear
        self.averageVote = averageVote
        
        if let backdropPath = backdropImagePath {
            self.backdropImageURLMedium = URL(string: TheMovieDBAPI.imageBaseStr + "w500" + backdropPath)
            self.backdropImageURLHigh = URL(string: TheMovieDBAPI.imageBaseStr + "original" + backdropPath)
            self.backdropImageURLLow = URL(string: TheMovieDBAPI.imageBaseStr + "w45" + backdropPath)
        }
        
        if let posterImagePath = posterImagePath {
            self.posterImageURLMedium = URL(string: TheMovieDBAPI.imageBaseStr + "w500" + posterImagePath)
            self.posterImageURLHigh = URL(string: TheMovieDBAPI.imageBaseStr + "original" + posterImagePath)
            self.posterImageURLLow = URL(string: TheMovieDBAPI.imageBaseStr + "w45" + posterImagePath)
        }
        
    }
    
    
    class func movies(with dictionaries: [NSDictionary]) -> [Movie] {
        return dictionaries.map {Movie(dictionary: $0)}
    }
    
}

//
//  MoviesTableViewDataSource.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit

class MoviesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var movies = [Movie]()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieListCell", for: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.overViewLabel.text = movie.overview
        cell.releaseYearLabel.text = movie.releaseYear
        cell.posterImageView.contentMode = .scaleAspectFit
        cell.posterImageView.frame.size = CGSize(width: 100, height: 100)
        cell.averageVoteLabel.text = String(format: "%.1f", movie.averageVote ?? 0)
        
        if let posterImageURL = movie.posterImageURLMedium {
            cell.posterImageView.setImageWith(posterImageURL, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.posterImageView.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}

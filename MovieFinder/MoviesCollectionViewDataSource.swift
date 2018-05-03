//
//  MoviesCollectionViewDataSource.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import UIKit

class MoviesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var movies = [Movie]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as! MovieCollectionCell
        if let posterImageURL = movies[indexPath.row].posterImageURLMedium {
            cell.posterImageView.setImageWith(posterImageURL, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.posterImageView.image = UIImage(named: "placeholder")
        }
        return cell
    }
}

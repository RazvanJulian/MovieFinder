//
//  TheMovieDBAPI.swift
//  MovieFinder
//
//  Created by Razvan Julian on 30/04/2018.
//  Copyright © 2018 Razvan Julian. All rights reserved.
//

import Foundation


enum TheMovieDBErrors: Error {
    case networkFail(description: String)
    case jsonSerializationFail
    case dataNotReceived
    case castFail
    case internalError
    case unknown
}



extension TheMovieDBErrors: LocalizedError {
    public var errorDescription: String? {
        let defaultMessage = "Unknown error!"
        let internalErrorMessage = "Something's wrong! Please contact our support team."
        switch self {
        case .networkFail(let localizedDescription):
            print(localizedDescription)
            return localizedDescription
        case .jsonSerializationFail:
            return internalErrorMessage
        case .dataNotReceived:
            return internalErrorMessage
        case .castFail:
            return internalErrorMessage
        case .internalError:
            return internalErrorMessage
        case .unknown:
            return defaultMessage
        }
    }
}


@objc protocol TheMovieDBDelegate: NSObjectProtocol {
    func theMovieDB(didFinishUpdatingMovies movies: [Movie])
    @objc optional func theMovieDB(didFailWithError error: Error)
}


class TheMovieDBAPI: NSObject {
    
    static let APIKey: String = "2696829a81b1b5827d515ff121700838"
    static let imageBaseStr: String = "https://image.tmdb.org/t/p/"
    
    var delegate: TheMovieDBDelegate?
    var endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    
    func startUpdatingMovies() {
        var urlRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(TheMovieDBAPI.APIKey)")!)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler:
        { (data, response, error) in
            

            guard error == nil else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.networkFail(description: error!.localizedDescription))
                print("TheMovieDBAPI: \(error!.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.unknown)
                print("TheMovieDBAPI: Unknown error. Could not get response!")
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.internalError)
                print("TheMovieDBAPI: Response code was either 401 or 404.")
                return
            }
            
            guard let data = data else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.dataNotReceived)
                print("TheMovieDBAPI: Could not get data!")
                return
            }
            
            do {
                let movies = try self.movieObjects(with: data)
                self.delegate?.theMovieDB(didFinishUpdatingMovies: movies)
            } catch (let error) {
                self.delegate?.theMovieDB?(didFailWithError: error)
                print("TheMovieDBAPI: Some problem occurred during JSON serialization.")
                return
            }
            
        });
        task.resume()
    }
    
    
    
    func startSearchMovies(query: String) {
        var urlRequest = URLRequest(url: URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(TheMovieDBAPI.APIKey)&language=en-US&query=\(query.replacingOccurrences(of: " ", with: "%20"))")!)
        print([urlRequest])
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler:
        { (data, response, error) in
            
            
            guard error == nil else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.networkFail(description: error!.localizedDescription))
                print("TheMovieDBAPI: \(error!.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.unknown)
                print("TheMovieDBAPI: Unknown error. Could not get response!")
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.internalError)
                print("TheMovieDBAPI: Response code was either 401 or 404.")
                return
            }
            
            guard let data = data else {
                self.delegate?.theMovieDB?(didFailWithError: TheMovieDBErrors.dataNotReceived)
                print("TheMovieDBAPI: Could not get data!")
                return
            }
            
            do {
                let movies = try self.movieObjects(with: data)
                self.delegate?.theMovieDB(didFinishUpdatingMovies: movies)
            } catch (let error) {
                self.delegate?.theMovieDB?(didFailWithError: error)
                print("TheMovieDBAPI: Some problem occurred during JSON serialization.")
                return
            }
            
        });
        task.resume()
    }
    
    
    
    func movieObjects(with data: Data) throws -> [Movie] {
        do {
            
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw TheMovieDBErrors.castFail
            }
            
            guard let movieDictionaries = responseDictionary["results"] as? [NSDictionary] else {
                print("TheMovieDBAPI: Movie dictionary not found.")
                throw TheMovieDBErrors.unknown
            }
            
            return Movie.movies(with: movieDictionaries)
            
        } catch (let error) {
            print("TheMovieDBAPI: \(error.localizedDescription)")
            throw error
        }
    }
}

//
//  Movie.swift
//  MovieViewer
//
//  Created by qburst on 05/10/16.
//  Copyright © 2016 qburst. All rights reserved.
//

import UIKit

class Movie {
    
//MARK: Properties
    let movieName : String
    let movieOverview : String
    let releaseDate : String
    var movieImage: UIImage
   
    
//MARK: Initializer
    init (movieName: String,movieOverview: String,releaseDate: String,movieImage: UIImage) {
        self.movieName = movieName
        self.movieImage = movieImage
        self.movieOverview = movieOverview
        self.releaseDate = releaseDate
        
    }
}

    
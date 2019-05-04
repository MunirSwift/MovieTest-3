//
//  MainMovieCoding.swift
//  MovieTest
//
//  Created by Rydus on 05/05/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import Foundation

class MainMovieCoding : NSObject, NSCoding{
    
    var model: [MainMovieModel]?
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(self.model, forKey: "modelMainMovie");
    }
    
    init(models: [MainMovieModel]) { // Dictionary object
        self.model = models
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.model = aDecoder.decodeObject(forKey: "modelMainMovie") as? [MainMovieModel];
    }
}

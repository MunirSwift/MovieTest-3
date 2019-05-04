//
//  MainMovieParser.swift
//  MovieTest
//
//  Created by Rydus on 23/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainMovieParser {
    
    //  MARK:   High order function to filter result from model
    static func getTitleMovie(keyword:String, model:[MainMovieModel])->[MainMovieModel] {
        if !model.isEmpty {
            let j = model.filter({ (json) -> Bool in
                return json.title.lowercased().hasPrefix(keyword.lowercased()) }) as [MainMovieModel]
            return j
        }
        else {
            return []
        }
    }
}

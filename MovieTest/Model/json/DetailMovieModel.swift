//
//  DetailMovieModel.swift
//  MovieTest
//
//  Created by Rydus on 04/05/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import Foundation
import SwiftyJSON

//  MARK:   Detail Movie Json Model
struct DetailMovieModel {
    
    var backdrop_path:String = String()
    var belongs_to_collection = JSON()
    var imdb_id:String = String()
    var genres = Array<JSON>()
    var release_date:String = String()
    var overview:String = String()
    var id:Int
    
    init(json:JSON) {
        backdrop_path = json["backdrop_path"].stringValue
        belongs_to_collection = json["belongs_to_collection"] as JSON
        imdb_id = json["imdb_id"].stringValue
        genres = json["genres"].arrayValue as [JSON]
        release_date = json["release_date"].stringValue
        overview = json["overview"].stringValue
        id = json["id"].intValue
    }
}

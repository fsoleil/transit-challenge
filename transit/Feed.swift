//
//  Feed.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-15.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Feed: JsonDeserialize {
    
    let id: Int
    let name: String
    let code: String
    let latitude: Double
    let longitude: Double
    let city : String?
    let countryCode : String
    
    /// init feed object with a JSON
    /// - parameter json: JSON object
    /// - returns: Feed
    
    public init(withJson json: JSON) throws {
        
        // define latitude
        let latitudeMax:Double = try json["bounds"].from(key: "max_lat")
        let latitudeMin:Double = try json["bounds"].from(key: "min_lat")
        let latitude = (latitudeMax+latitudeMin)/2

        // define longitude
        let longitudeMax:Double = try json["bounds"].from(key: "max_lon")
        let longitudeMin:Double = try json["bounds"].from(key: "min_lon")
        let longitude = (longitudeMax+longitudeMin)/2
        
        try self.init(withId:json.from(key:"id"),
                      name:json.from(key:"name"),
                      code:json.from(key: "code"),
                      latitude:latitude,
                      longitude:longitude,
                      city:json.fromOptional(key: "location"),
                      countryCode:json.from(key: "country_code")
        )
        
    }
    
    /// init feed object
    /// - parameter id : feed id
    /// - parameter name : feed name
    /// - parameter code : feed code
    /// - returns: Feed
    
    init(withId id: Int,
         name: String,
         code: String,
         latitude: Double,
         longitude: Double,
         city: String?,
         countryCode: String
        ) {
        
        self.name = name
        self.id = id
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.countryCode = countryCode
    }
    
}

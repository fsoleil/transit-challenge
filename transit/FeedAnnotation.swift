//
//  FeedAnnotation.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import MapKit

class FeedAnnotation: NSObject,MKAnnotation
{
    
    var feed: Feed
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    /// init FeedAnnotation object
    /// - parameter feed : Feed
    /// - returns: FeedAnnotation
    
    init(withFeed feed: Feed) {
        
        self.coordinate = CLLocationCoordinate2D(latitude:feed.latitude, longitude: feed.longitude)
        self.title = feed.name
        self.subtitle = feed.city
        self.feed = feed
    }
    
    public var pinColor:String{
        get
        {
            return self.codeColor(withCountryCode: self.feed.countryCode);
        }
    }
    
    /// get code color
    /// - parameter countryCode : country code
    /// - returns: String
    
    func codeColor(withCountryCode countryCode:String) -> String {
        
        switch countryCode {
        case "US":
            return "e040fb"
        case "CA":
            return "f44336"
        case "FR":
            return "3f51b5"
        case "GB":
            return "8bc34a"
        case "DE":
            return "ffc107"
        default:
            return "00bcd4"
        }
    }
    
}

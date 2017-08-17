//
//  TransitWebServiceConfiguration.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON

public class TransitWebServiceConfiguration: WebServiceConfiguration {
    
    let baseUrl: URL
    
    /// init TransitWebServiceConfiguration object
    /// - parameter baseUrl: URL
    /// - returns: TransitWebServiceConfiguration
    
    public init(withBaseUrl baseUrl: URL) {
        
        self.baseUrl = baseUrl
    }
    
}

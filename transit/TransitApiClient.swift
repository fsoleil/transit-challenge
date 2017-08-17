//
//  transitApi.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation

protocol TransitApiClient {
    var webServiceClient: WebServiceClient { get set }
    var webServiceConfiguration: TransitWebServiceConfiguration { get set }
    var feedClient: DefaultFeedClient { get set }
}


class DefaultApiClient: TransitApiClient {
    
    var webServiceConfiguration: TransitWebServiceConfiguration
    var webServiceClient: WebServiceClient
    var feedClient: DefaultFeedClient
    
    init(withWebServiceClient webServiceClient: WebServiceClient, webServiceConfiguration: TransitWebServiceConfiguration) {
        self.webServiceClient = webServiceClient
        self.webServiceConfiguration = webServiceConfiguration
        
        self.feedClient = DefaultFeedClient(withWebServiceClient: webServiceClient,
                                            webServiceConfiguration: webServiceConfiguration)
    }
}

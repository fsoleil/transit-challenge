//
//  PatientClient.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

enum FeedsListResult {
    case success(feedsList:[Feed])
    case error(Error?)
}

enum FeedError: Error {
    case invalidJson
}

internal enum FeedEndpoint: Endpoint {
    
    case feedsList
    
    public var path: String {
        switch self {
        case .feedsList: return "v3/feeds?all=1&detailed=1"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .feedsList : return .get
        }
    }
}

protocol FeedClient {
    func feedsList() throws -> Promise<FeedsListResult>
}

class DefaultFeedClient: TransitBaseClient {
    
    var webServiceConfiguration: TransitWebServiceConfiguration
    var webServiceClient: WebServiceClient
    
    init(withWebServiceClient webServiceClient: WebServiceClient, webServiceConfiguration: TransitWebServiceConfiguration) {
        self.webServiceClient = webServiceClient
        self.webServiceConfiguration = webServiceConfiguration
    }
}

extension DefaultFeedClient:FeedClient{
    
    
    /// get feeds list
    /// - returns: Promise<PatientListResult>
    
    func feedsList() throws -> Promise<FeedsListResult>{
        
        let request = Request(withEndpoint:FeedEndpoint.feedsList)
        
        return Promise { fulfill, reject in
            
            firstly {
                try self.execute(request: request)
                }.then { (response: TransitWebserviceResponse) -> Void in
                    
                    switch response {
                    case .success(let json):
                        
                        if json["feeds"].exists() {
                            
                            // init feeds list
                            var feedsList: [Feed] = []
                            
                            // append feeds list
                            for profile in json["feeds"].arrayValue {
                                let feed: Feed = try profile.toModel()
                                feedsList.append(feed)
                            }
                            
                            fulfill(FeedsListResult.success(feedsList: feedsList))
                            
                        } else {
                            throw FeedError.invalidJson
                        }
                        
                        break
                    case .error(statusCode: _, error: let error):
                        fulfill(FeedsListResult.error(error))
                        break
                    }
                }.catch(execute: { (error) in
                    reject(error)
                })
        }
        
    }
    
    
}


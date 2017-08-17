//
//  MapViewModel.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import PromiseKit


class MapViewModel {
    
    let apiClient:TransitApiClient
    
    /// init TransitApiClient
    /// - parameter apiClient: transit api client
    /// - returns: MapViewModel
    
    init(withApiClient apiClient: TransitApiClient) {
        self.apiClient = apiClient
    }
    
    /// retrieve annotations list
    /// - returns: [FeedAnnotation]
    
    func getAnnotations(completion:@escaping(_ annotations: [FeedAnnotation]) -> Void) {
        
        var annotations: [FeedAnnotation] = []
        
        firstly {
            try self.apiClient.feedClient.feedsList()
            
            }.then { ( response: FeedsListResult) -> Void in
                switch response {
                case .success(feedsList:let feedsList):
                    
                    for item in feedsList {
                        annotations.append(FeedAnnotation(withFeed:item))
                    }
                    break
                default:
                    break
                }
            }.always {
                completion(annotations)
            }.catch { _ in
        }
        
    }
    
}

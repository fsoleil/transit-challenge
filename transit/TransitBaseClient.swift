//
//  BaseClient.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

public enum TransitWebServiceError: Error {
    case missingResponse
}

public enum TransitWebserviceResponse {
    case success(JSON)
    case error(statusCode:Int,error:Error?)
}

protocol TransitBaseClient {
    var webServiceClient: WebServiceClient { get set }
    var webServiceConfiguration: TransitWebServiceConfiguration { get set }
}

extension TransitBaseClient {
    
    /// Execute a request
    /// - parameter request: Request
    /// - throws: Can throw error
    /// - returns: Promise<TransitWebserviceResponse>
    
    public func execute(request: Request) throws -> Promise<TransitWebserviceResponse> {
        
        return Promise { fulfill, reject in
            firstly {
                try self.webServiceClient.send(
                    request: request,
                    withConfiguration: self.webServiceConfiguration)
                
                }.then { (response: WebServiceResponse) -> Void in
                    
                    switch response {
                    case .success(let data, let statusCode):
                        
                        try fulfill(self.processResponse(withStatusCode: statusCode, data: data))
                        
                    case .error(let error, let data, let statusCode):
                        
                        try fulfill(self.processResponse(withStatusCode: statusCode, data: data, error: error))
                        break
                    }
                    
                }.catch(execute: { (error) in
                    reject(error)
                })
        }
    }
    
    ///  request-response process
    /// - parameter statusCode: HttpResponseCode
    /// - parameter data: Data request response
    /// - parameter error: Request error
    /// - returns: TransitWebserviceResponse
    
    func processResponse( withStatusCode statusCode: HttpResponseCode,
                          data: Data?,
                          error: Error? = nil
        
        ) throws -> TransitWebserviceResponse {
        
        
        if statusCode >= 200 && statusCode < 300 {
            
            if let json = try self.json(fromData: data){
                return TransitWebserviceResponse.success(json)
            }
            
            throw TransitWebServiceError.missingResponse

        }
        
        return TransitWebserviceResponse.error(statusCode:statusCode,error:error)
        
    }
    
    ///  Convert Data to JSON
    /// - parameter data: Data
    /// - throws: Can throw error
    /// - returns: JSON
    
    func json(fromData data: Data?) throws -> JSON? {
        
        guard let data = data else {
            return nil
        }
        
        var jsonError: NSError?
        let json = JSON(data: data, error: &jsonError)
        
        if let error = jsonError {
            throw error
        }
        
        return json
        
    }
    
}

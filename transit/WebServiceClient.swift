//
//  WebServiceClient.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

typealias HttpResponseCode = Int

public enum WebServiceClientError: Error {
    case unsupportedMethod
    case unknownError
}

enum WebServiceResponse {
    case success(data: Data?, statusCode: HttpResponseCode)
    case error(error: Error, data: Data?, statusCode: HttpResponseCode)
}

protocol WebServiceClient {
    var urlSession: URLSession { get }
}

struct DefaultWebServiceClient:WebServiceClient {
    
    let urlSession: URLSession
    
    init(withURLSession urlSession:URLSession) {
        self.urlSession = urlSession
    }
}


extension WebServiceClient {
    
    func send(request: Request, withConfiguration configuration: WebServiceConfiguration) throws -> PromiseKit.Promise<WebServiceResponse> {
        
        switch request.endpoint.method {
        case .post:
            return try post(data: request.payload?.toJSON().rawData(), atURL: request.endpoint.url(withBaseUrl: configuration.baseUrl))
        case .get:
            return try get(withURL: request.endpoint.url(withBaseUrl: configuration.baseUrl))
            
        default:
            throw WebServiceClientError.unsupportedMethod
        }
        
    }
    
    internal func http(withURLRequest urlRequest: URLRequest) -> PromiseKit.Promise<WebServiceResponse> {
        
        return Promise { fulfill, _ in
            
            let dataTask = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                
                let statusCode = self.getStatusCode(forResponse: response)
                
                if statusCode >= 200 && statusCode < 300 {
                    
                    let wsResponse = WebServiceResponse.success(data: data, statusCode: HttpResponseCode(statusCode))
                    
                    fulfill(wsResponse)
                    
                } else {
                    
                    var responseError: Error
                    
                    print("Error with http status: \(statusCode)")
                    
                    if let error = error {
                        responseError = error
                    } else {
                        responseError = WebServiceClientError.unknownError
                    }
                    
                    if let data = data {
                        let dataString = String(data: data, encoding: String.Encoding.utf8)
                        print("Unknown error : \(String(describing: dataString))")
                    }
                    
                    let wsResponse = WebServiceResponse.error(error: responseError, data: data, statusCode: statusCode)
                    fulfill(wsResponse)
                    
                }
            }
            dataTask.resume()
        }
    }
    
    internal func get(withURL url: URL) -> PromiseKit.Promise<WebServiceResponse> {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return http(withURLRequest: request)
    }
    
    internal func post(data: Data?, atURL url: URL) -> PromiseKit.Promise<WebServiceResponse> {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let data = data {
            request.httpBody = data
        }

        return http(withURLRequest: request)
    }
    
    
    internal func getStatusCode(forResponse response: URLResponse?) -> Int {
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return 0
    }
    
}

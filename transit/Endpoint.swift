//
//  Endpoint.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum EndpointError: Error {
    case invalidURL
}

public protocol Endpoint {
    var path: String {get}
    var method: HTTPMethod {get}
}

extension Endpoint {

    func url(withBaseUrl baseUrl: URL?) throws -> URL {

        guard let url = URL(string: self.path, relativeTo:baseUrl)  else {
            throw EndpointError.invalidURL
        }

        return url

    }
}

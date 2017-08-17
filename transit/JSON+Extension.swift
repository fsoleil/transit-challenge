//
//  JSON+Extension.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright (c) 2017 True Key. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum MappingError: Error {
    case requiredValue(key : String)
    case wrongValueType(key : String, type: String)
    case mappingError
}

public extension JSON {

    public func from<T>(key: String) throws -> T {

        let raw =  self[key].rawValue
        if raw is NSNull {
            throw MappingError.requiredValue(key: key)
        }

        guard let value = raw as? T else {
            throw MappingError.wrongValueType(key: key, type : String(describing: type(of: raw)))
        }

        return value
    }

    public func fromOptional<T>(key: String) throws -> T? {

        let raw =  self[key].rawValue
        if raw is NSNull {
            return nil
        }

        guard let value = raw as? T else {
            throw MappingError.wrongValueType(key: key, type : String(describing: type(of: raw)))
        }

        return value
    }

    public func toModel<T: JsonDeserialize>() throws -> T {

            let o = try T(withJson:self)
            return o
    }
}

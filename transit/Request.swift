//
//  Request.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Request {

    let endpoint: Endpoint
    let payload: Payload?

    init(withEndpoint endpoint: Endpoint, payload: Payload?=nil) {
        self.endpoint = endpoint
        self.payload = payload
    }

}

//
//  JsonSerialize.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol JsonSerialize {

    func toJSON() -> JSON
}

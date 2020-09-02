//
//  JsonTransaccionInfo.swift
//  Transacciones
//
//  Created by Andres Marin on 26/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import Foundation
import HandyJSON

class JsonTransaccionInfo: HandyJSON {
    
    var transactionId: Int?
    var value: Int?
    var points: Int?
    
    required init() {}
}

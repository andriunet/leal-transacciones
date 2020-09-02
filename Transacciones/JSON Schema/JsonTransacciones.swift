//
//  JsonTransacciones.swift
//  Transacciones
//
//  Created by Andres Marin on 25/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import Foundation
import HandyJSON

class JsonTransacciones: HandyJSON {
    
    var id: Int?
    var userId: Int?
    var createdDate: String?
    var commerce: JsonCommerce?
    var branch: JsonBranch?
    
    var colorEstado = UIColor.yellow
    
    required init() {}
}

class JsonCommerce: HandyJSON {
    var id: Int?
    var name: String?
    var valueToPoints: Int?
    var branches: [JsonBranch]?
    
    required init() {}
}

class JsonBranch: HandyJSON {
    var id: Int?
    var name: String?
    
    required init() {}
}

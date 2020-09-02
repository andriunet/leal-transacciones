//
//  JsonUsuarios.swift
//  Transacciones
//
//  Created by Andres Marin on 26/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import Foundation
import HandyJSON

class JsonUsuarios: HandyJSON {
    
    var id: Int?
    var createdDate: String?
    var name: String?    
    var birthday: String?
    var photo: String?
    
    required init() {}
}

//
//  PolicyEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class PolicyEntity: CoreStoreObject {
    let body = Value.Optional<String>("body")
    let title = Value.Optional<String>("title")
    let url = Value.Optional<String>("url")
}

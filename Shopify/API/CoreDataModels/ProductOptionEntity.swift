//
//  ProductOptionEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class ProductOptionEntity: CoreStoreObject {
    let id = Value.Required<String>("id", initial: "")
    let name = Value.Required<String>("name", initial: "")
    let values = Value.Optional<NSData>("values")
    
    let product = Relationship.ToOne<ProductEntity>("product")
}

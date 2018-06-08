//
//  VariantOptionEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class VariantOptionEntity: CoreStoreObject {
    let name = Value.Optional<String>("name")
    let value = Value.Optional<String>("value")
    
    let productVariant = Relationship.ToOne<ProductVariantEntity>("productVariant")
}

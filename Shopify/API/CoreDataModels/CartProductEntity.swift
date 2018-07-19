//
//  CartProductEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class CartProductEntity: CoreStoreObject {
    let currency = Value.Optional<String>("currency")
    let id = Value.Optional<String>("id")
    let title = Value.Optional<String>("title")
    var quantity = Value.Optional<Int64>("quantity")
    
    let productVariant = Relationship.ToOne<ProductVariantEntity>("productVariant", inverse: { $0.cartProduct })
}

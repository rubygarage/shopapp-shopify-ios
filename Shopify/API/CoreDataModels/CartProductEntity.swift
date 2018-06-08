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
    let productId = Value.Optional<String>("productId")
    let productTitle = Value.Optional<String>("productTitle")
    var quantity = Value.Optional<Int64>("quantity")
    
    let productVariant = Relationship.ToOne<ProductVariantEntity>("productVariant", inverse: { $0.cartProduct })
}

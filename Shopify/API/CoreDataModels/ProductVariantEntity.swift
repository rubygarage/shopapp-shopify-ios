//
//  ProductVariantEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class ProductVariantEntity: CoreStoreObject {
    let id = Value.Required<String>("id", initial: "")
    let available = Value.Optional<Bool>("available")
    var price = Value.Required<NSDecimalNumber>("price", initial: 0) // Decimal
    let productId = Value.Optional<String>("productId")
    let title = Value.Optional<String>("title")
    
    let cartProduct = Relationship.ToOne<CartProductEntity>("cartProduct")
    let image = Relationship.ToOne<ImageEntity>("image")
    let product = Relationship.ToOne<ProductEntity>("product")
    let productBySelectedOptions = Relationship.ToOne<ProductEntity>("productBySelectedOptions")
    let selectedOptions = Relationship.ToManyUnordered<VariantOptionEntity>("selectedOptions", inverse: { $0.productVariant })
}

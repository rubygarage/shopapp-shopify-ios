//
//  ProductEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class ProductEntity: CoreStoreObject {
    let id = Value.Required<String>("id", initial: "")
    let discount = Value.Optional<String>("discount")
    let paginationValue = Value.Optional<NSData>("paginationValue")
    let productDescription = Value.Optional<String>("productDescription")
    let title = Value.Optional<String>("title")
    let type = Value.Optional<String>("type")
    
    let category = Relationship.ToOne<CategoryEntity>("category", inverse: { $0.products })
    let images = Relationship.ToManyUnordered<ImageEntity>("images", inverse: { $0.product })
    let options = Relationship.ToManyUnordered<ProductOptionEntity>("options", inverse: { $0.product })
    let variantBySelectedOptions = Relationship.ToOne<ProductVariantEntity>("variantBySelectedOptions", inverse: { $0.productBySelectedOptions })
    let variants = Relationship.ToManyUnordered<ProductVariantEntity>("variants", inverse: { $0.product })
}

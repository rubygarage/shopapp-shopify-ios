//
//  ImageEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class ImageEntity: CoreStoreObject {
    let id = Value.Required<String>("id", initial: "")
    let src = Value.Required<String>("src", initial: "")
    
    let category = Relationship.ToOne<CategoryEntity>("category")
    let product = Relationship.ToOne<ProductEntity>("product")
    let productVariant = Relationship.ToManyUnordered<ProductVariantEntity>("productVariant", inverse: { $0.image })
}

//
//  CategoryEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class CategoryEntity: CoreStoreObject {
    let id = Value.Required<String>("id", initial: "")
    let paginationValue = Value.Optional<NSData>("paginationValue")
    let title = Value.Required<String>("title", initial: "")
    
    let image = Relationship.ToOne<ImageEntity>("image", inverse: { $0.category })
    let products = Relationship.ToManyUnordered<ProductEntity>("products")
}

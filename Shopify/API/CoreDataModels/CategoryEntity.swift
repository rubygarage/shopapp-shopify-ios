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
    let additionalDescription1 = Value.Optional<String>("additionalDescription1")
    let categoryDescription = Value.Optional<String>("categoryDescription")
    let paginationValue = Value.Optional<NSData>("paginationValue")
    let title = Value.Required<String>("title", initial: "")
    let updatedAt = Value.Optional<Date>("updatedAt")
    
    let image = Relationship.ToOne<ImageEntity>("image", inverse: { $0.category })
    let products = Relationship.ToManyUnordered<ProductEntity>("products")
}

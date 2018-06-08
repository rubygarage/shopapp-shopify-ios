//
//  ProductVariantEntityUpdateService.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/8/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import CoreStore
import ShopApp_Gateway

struct ProductVariantEntityUpdateService {
    static func update(_ entity: ProductVariantEntity?, with item: ProductVariant?, transaction: AsynchronousDataTransaction) {
        guard let entity = entity, let item = item else {
            return
        }
        
        entity.id.value = item.id
        entity.price.value = NSDecimalNumber(decimal: item.price ?? Decimal())
        entity.title.value = item.title
        entity.available.value = item.available
        entity.productId.value = item.productId
        
        if let selectedOptions = item.selectedOptions {
            selectedOptions.forEach {
                let variantOptionEntity: VariantOptionEntity = transaction.create(Into<VariantOptionEntity>())
                VariantOptionEntityUpdateService.update(variantOptionEntity, with: $0)
                entity.selectedOptions.value.insert(variantOptionEntity)
            }
        }
        
        if let imageItem = item.image {
            let predicate = NSPredicate(format: "id = %@", imageItem.id)
            let imageEntity: ImageEntity? = transaction.fetchOrCreate(predicate: predicate)
            ImageEntityUpdateService.update(imageEntity, with: imageItem)
            entity.image.value = imageEntity
        }
    }
}

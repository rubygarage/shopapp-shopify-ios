//
//  CartProductEntityUpdateService.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/8/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import CoreStore
import ShopApp_Gateway

struct CartProductEntityUpdateService {
    static func update(_ entity: CartProductEntity, with item: CartProduct, transaction: AsynchronousDataTransaction) {
        entity.id.value = item.id
        entity.title.value = item.title
        entity.quantity.value = Int64(item.quantity)
        entity.currency.value = item.currency
        
        let predicate = NSPredicate(format: "id = %@", item.productVariant?.id ?? "")
        let variant: ProductVariantEntity = transaction.fetchOrCreate(predicate: predicate)
        
        if let productVariant = item.productVariant {
            ProductVariantEntityUpdateService.update(variant, with: productVariant, transaction: transaction)
        }
        
        entity.productVariant.value = variant
    }
}

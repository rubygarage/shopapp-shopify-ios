//
//  CoreDataCartProductAdapter.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/8/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

struct CoreDataCartProductAdapter {
    static func adapt(item: CartProductEntity?) -> CartProduct? {
        guard let item = item else {
            return nil
        }
        
        let id = item.productVariant.value?.id.value ?? ""
        let productVariant = CoreDataProductVariantAdapter.adapt(item: item.productVariant.value)
        let title = item.title.value ?? ""
        let currency = item.currency.value ?? ""
        let quantity = Int(item.quantity.value ?? 0)
    
        return CartProduct(id: id, productVariant: productVariant, title: title, currency: currency, quantity: quantity)
    }
}

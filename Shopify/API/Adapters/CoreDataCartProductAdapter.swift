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
        
        let cartProduct = CartProduct()
        cartProduct.productId = item.productId.value
        cartProduct.productTitle = item.productTitle.value
        cartProduct.productVariant = CoreDataProductVariantAdapter.adapt(item: item.productVariant.value)
        cartProduct.currency = item.currency.value
        cartProduct.quantity = Int(item.quantity.value ?? 0)
        cartProduct.cartItemId = item.productVariant.value?.id.value ?? ""
        
        return cartProduct
    }
}

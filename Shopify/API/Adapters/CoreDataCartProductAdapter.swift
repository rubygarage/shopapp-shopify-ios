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
        cartProduct.productId = item.productId
        cartProduct.productTitle = item.productTitle
        cartProduct.productVariant = CoreDataProductVariantAdapter.adapt(item: item.productVariant)
        cartProduct.currency = item.currency
        cartProduct.quantity = Int(item.quantity)
        
        return cartProduct
    }
}

//
//  ShopifyOrderProductAdapter.swift
//  Shopify
//
//  Created by Radyslav Krechet on 1/4/18.
//  Copyright © 2018 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyOrderProductAdapter {
    static func adapt(item: Storefront.OrderLineItem?) -> OrderProduct? {
        guard let item = item else {
            return nil
        }

        var productVariant: ProductVariant?
        if let variant = item.variant {
            productVariant = ShopifyProductVariantAdapter.adapt(item: variant, productId: variant.product.id, productImage: variant.product.images.edges.first?.node)

//            if variant.product.options.count == 1 && variant.product.options.first?.values.count == 1 {
//                productVariant?.selectedOptions = nil
//            }
        }
        
        return OrderProduct(title: item.title, quantity: Int(item.quantity), productVariant: productVariant)
    }
}

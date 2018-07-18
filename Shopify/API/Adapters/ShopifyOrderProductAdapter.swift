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
    static func adapt(item: Storefront.OrderLineItem) -> OrderProduct {
        var productVariant: ProductVariant?
        
        if let variant = item.variant {
            productVariant = ShopifyProductVariantAdapter.adapt(item: variant)
        }
        
        return OrderProduct(title: item.title, quantity: Int(item.quantity), productVariant: productVariant)
    }
}

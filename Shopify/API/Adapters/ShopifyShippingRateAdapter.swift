//
//  ShopifyShippingRateAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 11/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyShippingRateAdapter {
    static func adapt(item: Storefront.ShippingRate?) -> ShippingRate? {
        guard let item = item else {
            return nil
        }

        return ShippingRate(title: item.title, price: item.price, handle: item.handle)
    }
}

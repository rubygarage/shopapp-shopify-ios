//
//  ShopifyLineItemAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 1/15/18.
//  Copyright © 2018 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyLineItemAdapter {
    static func adapt(item: Storefront.CheckoutLineItem) -> LineItem {
        let lineItem = LineItem()
        lineItem.id = item.id.rawValue
        lineItem.price = item.variant?.price
        lineItem.quantity = Int(item.quantity)
        
        return lineItem
    }
}

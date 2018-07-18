//
//  ShopifyCheckoutAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 11/20/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyCheckoutAdapter {
    static func adapt(item: Storefront.Checkout?) -> Checkout? {
        guard let item = item else {
            return nil
        }
        
        let shippingAddress = ShopifyAddressAdapter.adapt(item: item.shippingAddress)
        let availableShippingRates = item.availableShippingRates?.shippingRates?.flatMap { ShopifyShippingRateAdapter.adapt(item: $0) } ?? []
        
        let lineItemsNodes = item.lineItems.edges.map { $0.node }
        let lineItems = lineItemsNodes.flatMap { ShopifyLineItemAdapter.adapt(item: $0) }
        
        var shippingRate: ShippingRate?
        
        if let shippingLine = item.shippingLine {
            shippingRate = ShopifyShippingRateAdapter.adapt(item: shippingLine)
        }
        
        return Checkout(id: item.id.rawValue, subtotalPrice: item.subtotalPrice, totalPrice: item.totalPrice, currency: item.currencyCode.rawValue, shippingAddress: shippingAddress, shippingRate: shippingRate, availableShippingRates: availableShippingRates, lineItems: lineItems)
    }
}

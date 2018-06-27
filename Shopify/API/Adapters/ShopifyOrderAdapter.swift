//
//  ShopifyOrderAdapter.swift
//  Shopify
//
//  Created by Radyslav Krechet on 1/4/18.
//  Copyright © 2018 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyOrderAdapter {
    static func adapt(edgeItem: Storefront.OrderEdge?) -> Order? {
        return adapt(item: edgeItem?.node, paginationValue: edgeItem?.cursor)
    }

    static func adapt(item: Storefront.Order?, paginationValue: String? = nil) -> Order? {
        guard let item = item, let shippingAddress = ShopifyAddressAdapter.adapt(item: item.shippingAddress) else {
            return nil
        }

        let lineItemsNodes = item.lineItems.edges.map { $0.node }
        let orderProducts = lineItemsNodes.flatMap { ShopifyOrderProductAdapter.adapt(item: $0) }

        return Order(id: item.id.rawValue, currencyCode: item.currencyCode.rawValue, orderNumber: Int(item.orderNumber), subtotalPrice: item.subtotalPrice, totalShippingPrice: item.totalShippingPrice, totalPrice: item.totalPrice, createdAt: item.processedAt, orderProducts: orderProducts, shippingAddress: shippingAddress, paginationValue: paginationValue)
    }
}


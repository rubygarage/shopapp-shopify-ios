//
//  ShopifyCategoryAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyCategoryAdapter {
    static func adapt(item: Storefront.Collection, currency: String) -> ShopApp_Gateway.Category {
        return adapt(item: item, currency: currency)
    }

    static func adapt(edgeItem: Storefront.CollectionEdge, currency: String) -> ShopApp_Gateway.Category {
        return adapt(item: edgeItem.node, currency: currency, paginationValue: edgeItem.cursor)
    }

    // MARK: - Private

    private static func adapt(item: Storefront.Collection, currency: String, paginationValue: String? = nil) -> ShopApp_Gateway.Category {
        let image = ShopifyImageAdapter.adapt(item: item.image)
        let products = item.products.edges.map { ShopifyProductAdapter.adapt(edgeItem: $0, currency: currency) }
        
        return ShopApp_Gateway.Category(id: item.id.rawValue, title: item.title, image: image, products: products, paginationValue: paginationValue)
    }
}


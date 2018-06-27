//
//  ShopifyProductAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyProductAdapter {
    static func adapt(edgeItem: Storefront.ProductEdge, currency: String) -> Product {
        return adapt(item: edgeItem.node, currency: currency, paginationValue: edgeItem.cursor)
    }

    static func adapt(item: Storefront.Product, currency: String, paginationValue: String? = nil) -> Product {
        let imagesNodes = item.images.edges.map { $0.node }
        let images = imagesNodes.flatMap { ShopifyImageAdapter.adapt(item: $0) }

        let variantsNodes = item.variants.edges.map { $0.node }
        let variants = variantsNodes.flatMap { ShopifyProductVariantAdapter.adapt(item: $0, productId: item.id, productImage: item.images.edges.first?.node) }

        let variantsPrices = variants.map({ $0.price }).sorted(by: { $0 < $1 })
        let price = variantsPrices.first ?? 0.0
        let hasAlternativePrice = variantsPrices.min() ?? 0.0 != variantsPrices.max() ?? 0.0

        let options = item.options.flatMap { ShopifyProductOptionAdapter.adapt(item: $0) }

//        if let options = product.options, options.count == 1 && options.first?.values?.count == 1 {
//            product.variants?.forEach {
//                $0.title = ""
//            }
//        }

        return Product(id: item.id.rawValue, title: item.title, productDescription: item.description, price: price, hasAlternativePrice: hasAlternativePrice, currency: currency, images: images, type: item.productType, paginationValue: paginationValue, variants: variants, options: options)
    }
}

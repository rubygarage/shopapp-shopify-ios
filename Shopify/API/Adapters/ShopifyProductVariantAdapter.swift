//
//  ShopifyProductVariantAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyProductVariantAdapter {
    static func adapt(item: Storefront.ProductVariant?) -> ProductVariant? {
        guard let item = item else {
            return nil
        }

        let image = ShopifyImageAdapter.adapt(item: item.image) ?? ShopifyImageAdapter.adapt(item: item.product.images.edges.first?.node)
        
        var selectedOptions = item.selectedOptions.flatMap { ShopifyVariantOptionAdapter.adapt(item: $0) }
        var selectedOptionsNames = selectedOptions.map { $0.name }
        
        for option in item.product.options {
            if option.values.count <= 1, let index = selectedOptionsNames.index(of: option.name) {
                selectedOptions.remove(at: index)
                selectedOptionsNames.remove(at: index)
            }
        }
        
        let title = selectedOptions.isEmpty ? "" : item.title
        
        return ProductVariant(id: item.id.rawValue, title: title, price: item.price, isAvailable: item.availableForSale, image: image, selectedOptions: selectedOptions, productId: item.product.id.rawValue)
    }
}

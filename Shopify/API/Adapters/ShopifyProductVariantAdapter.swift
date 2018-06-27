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
    static func adapt(item: Storefront.ProductVariant?, productId: GraphQL.ID?, productImage: Storefront.Image?) -> ProductVariant? {
        guard let item = item else {
            return nil
        }

        let image = ShopifyImageAdapter.adapt(item: item.image) ?? ShopifyImageAdapter.adapt(item: productImage)
        let selectedOptions = item.selectedOptions.flatMap { ShopifyVariantOptionAdapter.adapt(item: $0) }
        let id = productId?.rawValue ?? ""
        
        return ProductVariant(id: item.id.rawValue, title: item.title, price: item.price, isAvailable: item.availableForSale, image: image, selectedOptions: selectedOptions, productId: id)
    }
}

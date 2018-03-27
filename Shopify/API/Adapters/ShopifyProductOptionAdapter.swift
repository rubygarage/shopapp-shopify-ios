//
//  ShopifyProductOptionAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyProductOptionAdapter {
    static func adapt(item: Storefront.ProductOption?) -> ProductOption? {
        guard let item = item else {
            return nil
        }

        let productOption = ProductOption()
        productOption.id = item.id.rawValue
        productOption.name = item.name
        productOption.values = item.values
        return productOption
    }
}

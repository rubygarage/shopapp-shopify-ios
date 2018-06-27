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

        return ProductOption(id: item.id.rawValue, name: item.name, values: item.values)
    }
}

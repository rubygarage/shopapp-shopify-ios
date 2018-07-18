//
//  ShopifyVariantOptionAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 11/6/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyVariantOptionAdapter {
    static func adapt(item: Storefront.SelectedOption) -> VariantOption {
        return VariantOption(name: item.name, value: item.value)
    }
}

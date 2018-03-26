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
    static func adapt(item: Storefront.SelectedOption?) -> VariantOption? {
        guard let item = item else {
            return nil
        }

        let variantOption = VariantOption()
        variantOption.name = item.name
        variantOption.value = item.value
        return variantOption
    }
}

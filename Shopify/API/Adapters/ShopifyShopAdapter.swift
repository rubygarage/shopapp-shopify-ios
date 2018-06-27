//
//  ShopifyShopAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/23/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyShopAdapter {
    static func adapt(item: Storefront.Shop) -> Shop {
        let privacyPolicy = ShopifyPolicyAdapter.adapt(item: item.privacyPolicy)
        let refundPolicy = ShopifyPolicyAdapter.adapt(item: item.refundPolicy)
        let termsOfService = ShopifyPolicyAdapter.adapt(item: item.termsOfService)
        
        return Shop(privacyPolicy: privacyPolicy, refundPolicy: refundPolicy, termsOfService: termsOfService)
    }
}

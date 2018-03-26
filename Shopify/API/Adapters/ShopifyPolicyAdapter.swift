//
//  ShopifyPolicyAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyPolicyAdapter {
    static func adapt(item: Storefront.ShopPolicy?) -> Policy? {
        guard let item = item else {
            return nil
        }

        let policy = Policy()
        policy.title = item.title
        policy.body = item.body
        policy.url = item.url.absoluteString
        return policy
    }
}

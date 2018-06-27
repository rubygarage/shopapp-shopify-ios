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

        return Policy(title: item.title, body: item.body, url: item.url.absoluteString)
    }
}

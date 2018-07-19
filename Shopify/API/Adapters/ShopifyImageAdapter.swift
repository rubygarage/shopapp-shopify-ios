//
//  ShopifyImageAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyImageAdapter {
    static func adapt(item: Storefront.Image?) -> Image? {
        guard let item = item else {
            return nil
        }

        return Image(id: item.id!.rawValue, src: item.src.absoluteString)
    }
}

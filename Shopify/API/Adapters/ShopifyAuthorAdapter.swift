//
//  ShopifyAuthorAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyAuthorAdapter {
    static func adapt(item: Storefront.ArticleAuthor) -> Author {
        return Author(firstName: item.firstName, lastName: item.lastName)
    }
}

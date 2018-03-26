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
    static func adapt(item: Storefront.ArticleAuthor?) -> Author? {
        guard let item = item else {
            return nil
        }

        let author = Author()
        author.firstName = item.firstName
        author.lastName = item.lastName
        author.fullName = item.name
        author.email = item.email
        author.bio = item.bio
        return author
    }
}

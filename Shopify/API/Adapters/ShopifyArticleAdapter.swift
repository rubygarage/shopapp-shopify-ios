//
//  ShopifyArticleAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/25/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyArticleAdapter {
    static func adapt(item: Storefront.Article, paginationValue: String? = nil) -> Article {
        let author = ShopifyAuthorAdapter.adapt(item: item.author)
        let image = ShopifyImageAdapter.adapt(item: item.image)
        
        return Article(id: item.id.rawValue, title: item.title, content: item.content, contentHtml: item.contentHtml, image: image, author: author, paginationValue: paginationValue)
    }

    static func adapt(item: Storefront.ArticleEdge) -> Article {
        return adapt(item: item.node, paginationValue: item.cursor)
    }
}

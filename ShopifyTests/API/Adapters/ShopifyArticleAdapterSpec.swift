//
//  ShopifyArticleAdapterSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/4/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyArticleAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Article(fields: ShopifyAdapterTestHelper.article)
                let object = ShopifyArticleAdapter.adapt(item: item)!
                
                self.compare(object, with: item)
            }
        }
        
        describe("when adapter used") {
            it("needs to adapt storefront edge to model object") {
                let edge = try! Storefront.ArticleEdge(fields: ShopifyAdapterTestHelper.articleEdge)
                let object = ShopifyArticleAdapter.adapt(item: edge)!
                
                self.compare(object, with: edge.node)

                expect(object.paginationValue) == edge.cursor
            }
        }
    }
    
    private func compare(_ object: Article, with item: Storefront.Article) {
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.content) == item.content
        expect(object.contentHtml) == item.contentHtml
        expect(object.author?.email) == item.author.email
        expect(object.tags) == item.tags
        expect(object.blogId) == item.blog.id.rawValue
        expect(object.blogTitle) == item.blog.title
        expect(object.publishedAt) == item.publishedAt
        expect(object.url) == item.url.absoluteString
        expect(object.image?.id) == item.image?.id?.rawValue
    }
}

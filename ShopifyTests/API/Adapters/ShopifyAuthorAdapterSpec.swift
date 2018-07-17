//
//  ShopifyAuthorAdapterSpec.swift
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

class ShopifyAuthorAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.ArticleAuthor(fields: ShopifyAdapterTestHelper.author)
                let object = ShopifyAuthorAdapter.adapt(item: item)
                
                expect(object.firstName) == item.firstName
                expect(object.lastName) == item.lastName
            }
        }
    }
}

//
//  ShopifyPolicyAdapterSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/5/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyPolicyAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to return nil if item is nil") {
                let object = ShopifyPolicyAdapter.adapt(item: nil)
                
                expect(object).to(beNil())
            }
            
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.ShopPolicy(fields: ShopifyAdapterTestHelper.shopPolicy)
                let object = ShopifyPolicyAdapter.adapt(item: item)!
                
                expect(object.title) == item.title
                expect(object.body) == item.body
                expect(object.url) == item.url.absoluteString
            }
        }
    }
}

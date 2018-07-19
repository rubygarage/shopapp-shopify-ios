//
//  ShopifyShopAdapterSpec.swift
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

class ShopifyShopAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Shop(fields: ShopifyAdapterTestHelper.shop)
                let object = ShopifyShopAdapter.adapt(item: item)
                
                expect(object.privacyPolicy?.title) == item.privacyPolicy?.title
                expect(object.refundPolicy?.title) == item.refundPolicy?.title
                expect(object.termsOfService?.title) == item.termsOfService?.title
            }
        }
    }
}

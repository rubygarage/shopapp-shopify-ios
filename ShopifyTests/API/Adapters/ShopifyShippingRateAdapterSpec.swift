//
//  ShopifyShippingRateAdapterSpec.swift
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

class ShopifyShippingRateAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.ShippingRate(fields: ShopifyAdapterTestHelper.shippingRate)
                let object = ShopifyShippingRateAdapter.adapt(item: item)!
                
                expect(object.title) == item.title
                expect(object.price) == item.price.description
                expect(object.handle) == item.handle
            }
        }
    }
}

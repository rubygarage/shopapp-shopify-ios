//
//  ShopifyLineItemAdapterSpec.swift
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

class ShopifyLineItemAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.CheckoutLineItem(fields: ShopifyAdapterTestHelper.checkoutLineItem)
                let object = ShopifyLineItemAdapter.adapt(item: item)
                
                expect(object.id) == item.id.rawValue
                expect(object.price) == item.variant?.price
                expect(object.quantity) == Int(item.quantity)
            }
        }
    }
}

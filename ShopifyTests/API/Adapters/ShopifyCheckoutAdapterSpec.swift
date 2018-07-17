//
//  ShopifyCheckoutAdapterSpec.swift
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

class ShopifyCheckoutAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Checkout(fields: ShopifyAdapterTestHelper.checkout)
                let object = ShopifyCheckoutAdapter.adapt(item: item)!
                
                expect(object.id) == item.id.rawValue
                expect(object.currency) == item.currencyCode.rawValue
                expect(object.subtotalPrice) == item.subtotalPrice
                expect(object.totalPrice) == item.totalPrice
                expect(object.shippingRate?.title) == item.shippingLine?.title
                expect(object.shippingAddress?.id) == item.shippingAddress?.id.rawValue
                expect(object.lineItems.first?.id) ==  item.lineItems.edges.first?.node.id.rawValue
                expect(object.availableShippingRates.first?.title) == item.availableShippingRates?.shippingRates?.first?.title
            }
        }
    }
}

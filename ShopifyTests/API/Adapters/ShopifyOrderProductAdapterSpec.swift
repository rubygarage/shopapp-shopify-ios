//
//  ShopifyOrderItemAdapterSpec.swift
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

class ShopifyOrderProductAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.OrderLineItem(fields: ShopifyAdapterTestHelper.orderLineItem)
                let object = ShopifyOrderProductAdapter.adapt(item: item)!
                
                expect(object.quantity) == Int(item.quantity)
                expect(object.title) == item.title
                expect(object.productVariant?.id) == item.variant?.id.rawValue
            }
        }
    }
}

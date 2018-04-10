//
//  ShopifyProductOptionAdapterSpec.swift
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

class ShopifyProductOptionAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.ProductOption(fields: ShopifyAdapterTestHelper.option)
                let object = ShopifyProductOptionAdapter.adapt(item: item)!
                
                expect(object.id) == item.id.rawValue
                expect(object.name) == item.name
                expect(object.values) == item.values
            }
        }
    }
}

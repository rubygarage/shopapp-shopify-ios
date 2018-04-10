//
//  ShopifyVariantOptionAdapterSpec.swift
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

class ShopifyVariantOptionAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.SelectedOption(fields: ShopifyAdapterTestHelper.selectedOption)
                let object = ShopifyVariantOptionAdapter.adapt(item: item)!
                
                expect(object.name) == item.name
                expect(object.value) == item.value
            }
        }
    }
}

//
//  ShopifyRepoErrorAdapterSpec.swift
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

class ShopifyRepoErrorAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.UserError(fields: ShopifyAdapterTestHelper.error)
                let object = ShopifyRepoErrorAdapter.adapt(item: item)!
                
                expect(object.errorMessage) == item.message
            }
        }
    }
}

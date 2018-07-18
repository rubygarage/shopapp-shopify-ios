//
//  ShopifyStateAdapterSpec.swift
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

class ShopifyStateAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to return empty model object with empty json") {
                let item = ShopifyAdapterTestHelper.emptyProvince as [String: AnyObject]
                let object = ShopifyStateAdapter.adapt(item: item)
                
                expect(object.name) == ""
            }
            
            it("needs to adapt api json to model object") {
                let item = ShopifyAdapterTestHelper.province as [String: AnyObject]
                let object = ShopifyStateAdapter.adapt(item: item)
                
                expect(object.name) == item["name"] as? String
            }
        }
    }
}

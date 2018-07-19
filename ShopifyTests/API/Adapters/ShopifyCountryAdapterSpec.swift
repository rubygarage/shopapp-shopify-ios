//
//  ShopifyCountryAdapterSpec.swift
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

class ShopifyCountryAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to return empty model object with empty json") {
                let item = ShopifyAdapterTestHelper.emptyCountry as [String: AnyObject]
                let object = ShopifyCountryAdapter.adapt(item: item)
                
                expect(object.name) == ""
                expect(object.states).to(beNil())
            }
            
            it("needs to adapt api json to model object") {
                let item = ShopifyAdapterTestHelper.country as [String: AnyObject]
                let object = ShopifyCountryAdapter.adapt(item: item)
                
                expect(object.name) == item["name"] as? String
                expect(object.states?.first?.name) == (item["provinces"] as? [ApiJson])?.first?["name"] as? String
            }
        }
    }
}

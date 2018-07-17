//
//  ShopifyAddressAdapterSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/4/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAddressAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.MailingAddress(fields: ShopifyAdapterTestHelper.mailingAddress)
                let object = ShopifyAddressAdapter.adapt(item: item)!
                
                expect(object.id) == item.id.rawValue
                expect(object.firstName) == item.firstName
                expect(object.lastName) == item.lastName
                expect(object.street) == item.address1
                expect(object.secondStreet) == item.address2
                expect(object.city) == item.city
                expect(object.country) == item.country
                expect(object.state) == item.province
                expect(object.zip) == item.zip
                expect(object.phone) == item.phone
            }
        }
    }
}

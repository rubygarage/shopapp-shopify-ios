//
//  ShopifyCustomerAdapterSpec.swift
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

class ShopifyCustomerAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Customer(fields: ShopifyAdapterTestHelper.customer)
                let object = ShopifyCustomerAdapter.adapt(item: item)!
                
                expect(object.email) == item.email
                expect(object.firstName) == item.firstName
                expect(object.lastName) == item.lastName
                expect(object.phone) == item.phone
                expect(object.promo) == item.acceptsMarketing
                expect(object.defaultAddress?.id) == item.defaultAddress?.id.rawValue
                expect(object.addresses?.first?.id) == item.addresses.edges.first?.node.id.rawValue
            }
        }
    }
}

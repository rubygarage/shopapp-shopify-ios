//
//  ShopifyAPIShopSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPIShopSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when get shop info called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ShopifyAPITestHelper.shop])
                    
                    self.shopifyAPI.getShop() { (shop, error) in
                        expect(shop).toNot(beNil())
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getShop() { (shop, error) in
                            expect(shop).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
    }
}

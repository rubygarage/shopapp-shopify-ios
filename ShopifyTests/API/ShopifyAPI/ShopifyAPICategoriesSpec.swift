//
//  ShopifyAPICategoriesSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/12/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick

@testable import Shopify

class ShopifyAPICategoriesSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when get category list called") {
            context("if success") {
                it("should return success response") {
                    let paymentSetting = ShopifyAPITestHelper.paymentSetting
                    let categories = [ShopifyAPITestHelper.collectionEdge]
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["collections": ["edges": categories],
                                                                                                   "paymentSettings": paymentSetting]])
                    
                    self.shopifyAPI.getCategoryList(perPage: 10, paginationValue: nil, sortBy: nil, reverse: false) { (categories, error) in
                        expect(categories?.first?.id) == ShopifyAPITestHelper.collection["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getCategoryList(perPage: 10, paginationValue: nil, sortBy: nil, reverse: false) { (categories, error) in
                            expect(categories?.count) == 0
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get category details called") {
            context("if success") {
                it("should return success response") {
                    let paymentSetting = ShopifyAPITestHelper.paymentSetting
                    let category = ShopifyAPITestHelper.collection
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": category,
                                                                                          "shop": ["paymentSettings": paymentSetting]])
                    
                    self.shopifyAPI.getCategoryDetails(id: "id", perPage: 1, paginationValue: nil, sortBy: nil, reverse: false) { (category, error) in
                        expect(category?.id) == ShopifyAPITestHelper.collection["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getCategoryDetails(id: "id", perPage: 1, paginationValue: nil, sortBy: nil, reverse: false) { (category, error) in
                            expect(category).to(beNil())
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
    }
}

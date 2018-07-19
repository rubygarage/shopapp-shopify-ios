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
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPICategoriesSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when get category list called") {
            context("if success") {
                it("should return success response") {
                    let paymentSetting = ShopifyAPITestHelper.paymentSettings
                    let categories = [ShopifyAPITestHelper.collectionEdge]
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["collections": ["edges": categories],
                                                                                                   "paymentSettings": paymentSetting]])
                    
                    self.shopifyAPI.getCategories(perPage: 10, paginationValue: nil) { (categories, error) in
                        expect(categories?.first?.id) == ShopifyAPITestHelper.collection["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getCategories(perPage: 10, paginationValue: nil) { (categories, error) in
                            expect(categories).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get category details called") {
            context("if success response") {
                context("and node exist") {
                    it("should return success response") {
                        let paymentSetting = ShopifyAPITestHelper.paymentSettings
                        let category = ShopifyAPITestHelper.collection
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": category,
                                                                                              "shop": ["paymentSettings": paymentSetting]])
                        
                        self.shopifyAPI.getCategory(id: "id", perPage: 1, paginationValue: nil, sortBy: nil) { (category, error) in
                            expect(category?.id) == ShopifyAPITestHelper.collection["id"] as? String
                            expect(error).to(beNil())
                        }
                    }
                }
                
                context("or node doesn't exist") {
                    it("should return error with CriticalError type") {
                        let paymentSetting = ShopifyAPITestHelper.paymentSettings
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": NSNull(),
                                                                                              "shop": ["paymentSettings": paymentSetting]])
                        
                        self.shopifyAPI.getCategory(id: "id", perPage: 1, paginationValue: nil, sortBy: nil) { (category, error) in
                            expect(category).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getCategory(id: "id", perPage: 1, paginationValue: nil, sortBy: nil) { (category, error) in
                            expect(category).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
            
            context("if response and error are nil") {
                it("should return error with ContentError type") {
                    self.clientMock.clear()
                    
                    self.shopifyAPI.getCategory(id: "id", perPage: 1, paginationValue: nil, sortBy: nil) { (category, error) in
                        expect(category).to(beNil())
                        expect(error) == ShopAppError.content(isNetworkError: false)
                    }
                }
            }
        }
    }
}

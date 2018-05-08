//
//  ShopifyAPIProductsSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/11/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPIProductsSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when get product list called") {
            context("if success") {
                it("should return success response") {
                    let paymentSetting = ShopifyAPITestHelper.paymentSettings
                    let productsEdges = ShopifyAPITestHelper.productsEdges
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["products": ["edges": productsEdges],
                                                                                                   "paymentSettings": paymentSetting]])
                    
                    self.shopifyAPI.getProductList(perPage: 10, paginationValue: nil, sortBy: nil, keyPhrase: nil, excludePhrase: nil, reverse: false) { (products, error) in
                        expect(products?.first?.id) == ShopifyAPITestHelper.product["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getProductList(perPage: 10, paginationValue: nil, sortBy: nil, keyPhrase: nil, excludePhrase: nil, reverse: false) { (products, error) in
                            expect(products?.count) == 0
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get product called") {
            context("if success response") {
                context("and node exist in response") {
                    it("should return response") {
                        let product = ShopifyAPITestHelper.product
                        let paymentSetting = ShopifyAPITestHelper.paymentSettings
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": product,
                                                                                              "shop": ["paymentSettings": paymentSetting]])
                        
                        self.shopifyAPI.getProduct(id: "id") { (product, error) in
                            expect(product?.id) == ShopifyAPITestHelper.product["id"] as? String
                            expect(error).to(beNil())
                        }
                    }
                }
                
                context("or node doesn't exist in response") {
                    it("should return critical error") {
                        let paymentSetting = ShopifyAPITestHelper.paymentSettings
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": NSNull(),
                                                                                              "shop": ["paymentSettings": paymentSetting]])
                        
                        self.shopifyAPI.getProduct(id: "id") { (product, error) in
                            expect(product).to(beNil())
                            expect(error is CriticalError) == true
                        }
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getProduct(id: "id") { (product, error) in
                            expect(product).to(beNil())
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
            
            context("if response and error are nil") {
                it("should return content error") {
                    self.clientMock.clear()
                    
                    self.shopifyAPI.getProduct(id: "id") { (product, error) in
                        expect(product).to(beNil())
                        expect(error is ContentError) == true
                    }
                }
            }
        }
        
        describe("when search products called") {
            context("if success") {
                it("should return success response") {
                    let paymentSetting = ShopifyAPITestHelper.paymentSettings
                    let productsEdges = ShopifyAPITestHelper.productsEdges
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["products": ["edges": productsEdges],
                                                                                                   "paymentSettings": paymentSetting]])
                    
                    self.shopifyAPI.searchProducts(perPage: 1, paginationValue: nil, searchQuery: "search phrase") { (products, error) in
                        expect(products?.first?.id) == ShopifyAPITestHelper.product["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.searchProducts(perPage: 1, paginationValue: nil, searchQuery: "search phrase") { (products, error) in
                            expect(products?.count) == 0
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get product variant list called") {
            context("if success") {
                it("should return success response") {
                    let productVariants = [ShopifyAPITestHelper.variant]
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["nodes": productVariants])
                    
                    self.shopifyAPI.getProductVariantList(ids: []) { (productVariants, error) in
                        expect(productVariants?.first?.id) == ShopifyAPITestHelper.variant["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getProductVariantList(ids: []) { (productVariants, error) in
                            expect(productVariants?.count) == 0
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
    }
}

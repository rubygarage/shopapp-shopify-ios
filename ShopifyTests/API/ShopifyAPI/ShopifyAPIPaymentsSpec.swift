//
//  ShopifyAPIPaymentsSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/13/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

class ShopifyAPIPaymentsSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when create chackout called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCreate": ["checkout": ShopifyAPITestHelper.checkout]])
                    
                    self.shopifyAPI.createCheckout(cartProducts: []) { (checkout, error) in
                        expect(checkout?.id) == ShopifyAPITestHelper.checkout["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of user error") {
                    it("should return user error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCreate": ["checkout": NSNull(),
                                                                                                                        "userErrors": ShopifyAPITestHelper.checkoutCreateUserErrors]])
                        
                        self.shopifyAPI.createCheckout(cartProducts: []) { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error?.errorMessage) == "Error message"
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCreate": ["checkout": NSNull(),
                                                                                                                        "userErrors": []]])
                        
                        self.shopifyAPI.createCheckout(cartProducts: []) { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
        }
        
        describe("when get checkout called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.checkout])
                    
                    self.shopifyAPI.getCheckout(with: "id") { (checkout, error) in
                        expect(checkout?.id) == ShopifyAPITestHelper.checkout["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of server error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { errorMessage in
                            self.shopifyAPI.getCheckout(with: "id") { (checkout, error) in
                                expect(checkout).to(beNil())
                                expect(error?.errorMessage) == errorMessage
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because checkout nil and error didn't occure") {
                    it("should return content error") {
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": NSNull()])
                        
                        self.shopifyAPI.getCheckout(with: "id") { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
        }
        
        describe("when update shipping address called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingAddressUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                    
                    self.shopifyAPI.updateShippingAddress(with: "CheckoutID", address: Address()) { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if user error occured") {
                context("because of user error") {
                    it("should return user error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingAddressUpdate": ["checkout": ["shippingAddress": NSNull()],
                                                                                                                                       "userErrors": ShopifyAPITestHelper.checkoutCreateUserErrors]])
                        
                        self.shopifyAPI.updateShippingAddress(with: "CheckoutID", address: Address()) { (success, error) in
                            expect(success) == false
                            expect(error?.errorMessage) == ShopifyAPITestHelper.checkoutCreateUserErrors.first!["message"] as? String
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return content error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.updateShippingAddress(with: "CheckoutID", address: Address()) { (success, error) in
                                expect(success) == false
                                expect(error is ContentError) == true
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
            }
        }
        
        describe("when get shipping rates called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.checkout])
                    
                    self.shopifyAPI.getShippingRates(with: "CheckoutID") { (rates, error) in
                        expect(rates?.first?.title) == ShopifyAPITestHelper.shippingRate["title"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getShippingRates(with: "CheckoutID") { (rates, error) in
                            expect(rates).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when update checkout called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                    
                    self.shopifyAPI.updateCheckout(with: ShippingRate(), checkoutId: "CheckoutID") { (checkout, error) in
                        expect(checkout?.id) == ShopifyAPITestHelper.checkout["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of server error") {
                    it("should return content error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.updateCheckout(with: ShippingRate(), checkoutId: "CheckoutID") { (checkout, error) in
                                expect(checkout).to(beNil())
                                expect(error is ContentError) == true
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because of response and error doesn't exist") {
                    it("should return content error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": NSNull()]])
                        
                        self.shopifyAPI.updateCheckout(with: ShippingRate(), checkoutId: "CheckoutID") { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
        }
        
        describe("when get shop currency called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ShopifyAPITestHelper.paymentSettings]])
                    
                    self.shopifyAPI.getShopCurrency() { (settings, error) in
                        expect(settings?.currencyCode.rawValue) == ShopifyAPITestHelper.paymentSettings["currencyCode"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getShopCurrency() { (settings, error) in
                            expect(settings).to(beNil())
                            expect(error).toNot(beNil())
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
    }
}

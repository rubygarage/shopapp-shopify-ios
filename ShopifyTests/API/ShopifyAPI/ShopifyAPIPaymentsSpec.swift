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
        
        describe("when create checkout called") {
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
                                                                                                                        "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.createCheckout(cartProducts: []) { (checkout, error) in
                            let message = ShopifyAPITestHelper.userErrors.first?["message"] as? String ?? ""
                            expect(checkout).to(beNil())
                            expect(error) == ShopAppError.nonCritical(message: message)
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCreate": ["checkout": NSNull(),
                                                                                                                        "userErrors": []]])
                        
                        self.shopifyAPI.createCheckout(cartProducts: []) { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                }
            }
        }
        
        describe("when get checkout called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.checkout])
                    
                    self.shopifyAPI.getCheckout(id: "id") { (checkout, error) in
                        expect(checkout?.id) == ShopifyAPITestHelper.checkout["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of server error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { errorMessage in
                            self.shopifyAPI.getCheckout(id: "id") { (checkout, error) in
                                expect(checkout).to(beNil())
                                expect(error) == ShopAppError.content(isNetworkError: false)
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because checkout nil and error didn't occure") {
                    it("should return content error") {
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": NSNull()])
                        
                        self.shopifyAPI.getCheckout(id: "id") { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                }
            }
        }

        describe("when update shipping address called") {
            context("if success") {
                it("should return success response") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingAddressUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                    
                    self.shopifyAPI.setShippingAddress(checkoutId: "CheckoutID", address: TestHelper.fullAddress) { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if user error occured") {
                context("because of user error") {
                    it("should return user error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingAddressUpdate": ["checkout": ["shippingAddress": NSNull()],
                                                                                                                                       "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.setShippingAddress(checkoutId: "CheckoutID", address: TestHelper.fullAddress) { (success, error) in
                            let message = ShopifyAPITestHelper.userErrors.first?["message"] as? String ?? ""
                            expect(success) == false
                            expect(error) == ShopAppError.nonCritical(message: message)
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return content error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.setShippingAddress(checkoutId: "CheckoutID", address: TestHelper.fullAddress) { (success, error) in
                                expect(success) == false
                                expect(error) == ShopAppError.content(isNetworkError: false)
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
                    
                    self.shopifyAPI.getShippingRates(checkoutId: "CheckoutID") { (rates, error) in
                        expect(rates?.first?.title) == ShopifyAPITestHelper.shippingRate["title"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.getShippingRates(checkoutId: "CheckoutID") { (rates, error) in
                            expect(rates).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
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
                    
                    self.shopifyAPI.setShippingRate(checkoutId: "CheckoutID", shippingRate: TestHelper.shippingRate) { (checkout, error) in
                        expect(checkout?.id) == ShopifyAPITestHelper.checkout["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of server error") {
                    it("should return content error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.setShippingRate(checkoutId: "CheckoutID", shippingRate: TestHelper.shippingRate) { (checkout, error) in
                                expect(checkout).to(beNil())
                                expect(error) == ShopAppError.content(isNetworkError: false)
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because of response and error doesn't exist") {
                    it("should return content error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": NSNull()]])
                        
                        self.shopifyAPI.setShippingRate(checkoutId: "CheckoutID", shippingRate: TestHelper.shippingRate) { (checkout, error) in
                            expect(checkout).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
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
        
        describe("when pay called") {
            context("if success") {
                it("should return order") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ["cardVaultUrl": "CardVaultURL"]]])
                    self.cardClientMock.returnedResponse = "CardVaultToken"
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCompleteWithCreditCard": ["checkout": ShopifyAPITestHelper.checkout, "payment": ShopifyAPITestHelper.payment]])
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.checkout])
                    
                    self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                        expect(order?.id) == ShopifyAPITestHelper.order["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("during 'updateCheckout' step") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                                expect(order).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("during 'createCardVault' step") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                        self.clientMock.returnedError = self.generateQueryError()
                        
                        self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                            expect(order).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                }
                
                context("during private 'payWithCard' step") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ["cardVaultUrl": "CardVaultURL"]]])
                        
                        self.cardClientMock.returnedError = ShopAppError.critical
                        
                        self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                            expect(order).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                }
                
                context("during 'completePay' step") {
                    context("and returned user error") {
                        it("should return error") {
                            self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                            self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ["cardVaultUrl": "CardVaultURL"]]])
                            self.cardClientMock.returnedResponse = "CardVaultToken"
                            self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCompleteWithCreditCard": ["checkout": ShopifyAPITestHelper.checkout,
                                                                                                                                            "payment": NSNull(),
                                                                                                                                            "userErrors": ShopifyAPITestHelper.userErrors]])
                            
                            self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                                let message = ShopifyAPITestHelper.userErrors.first?["message"] as? String ?? ""
                                expect(order).to(beNil())
                                expect(error) == ShopAppError.nonCritical(message: message)
                            }
                        }
                    }
                    
                    context("or not user error") {
                        it("should return error") {
                            self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                            self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ["cardVaultUrl": "CardVaultURL"]]])
                            self.cardClientMock.returnedResponse = "CardVaultToken"
                            self.clientMock.returnedError = self.generateQueryError()
                            
                            self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                                expect(order).to(beNil())
                                expect(error) == ShopAppError.content(isNetworkError: false)
                            }
                        }
                    }
                }
                
                context("during 'completePayPolling' step") {
                    it("should return content error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutShippingLineUpdate": ["checkout": ShopifyAPITestHelper.checkout]])
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["paymentSettings": ["cardVaultUrl": "CardVaultURL"]]])
                        self.cardClientMock.returnedResponse = "CardVaultToken"
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["checkoutCompleteWithCreditCard": ["checkout": ShopifyAPITestHelper.checkout,
                                                                                                                                        "payment": ShopifyAPITestHelper.payment]])
                        self.clientMock.returnedError = self.generateQueryError()
                        
                        self.shopifyAPI.completeCheckout(checkout: TestHelper.checkoutWithShippingAddress, email: "user@mail.com", address: TestHelper.fullAddress, card: TestHelper.card) { (order, error) in
                            expect(order).to(beNil())
                            expect(error) == ShopAppError.content(isNetworkError: false)
                        }
                    }
                }
            }
        }
 
        describe("when setup apple pay called") {
            context("if error occured") {
                it("should return content error") {
                    self.clientMock.returnedError = self.generateQueryError()
                    
                    self.shopifyAPI.setupApplePay(checkout: TestHelper.checkoutWithShippingAddress, email: "email") { (order, error) in
                        expect(order).to(beNil())
                        expect(error) == ShopAppError.content(isNetworkError: false)
                    }
                }
            }
        }
    }
}

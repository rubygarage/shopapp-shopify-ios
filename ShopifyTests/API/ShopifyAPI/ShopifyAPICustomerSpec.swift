//
//  ShopifyAPICustomerSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/16/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import KeychainSwift
import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPICustomerSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when sign up called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerCreate": ["customer": ShopifyAPITestHelper.customer]])
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
                    
                    self.shopifyAPI.signUp(with: "user@mail.com", firstName: nil, lastName: nil, password: "password", phone: nil) { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of user error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerCreate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.signUp(with: "user@mail.com", firstName: nil, lastName: nil, password: "password", phone: nil) { (success, error) in
                            expect(success) == false
                            expect(error?.errorMessage) == ShopifyAPITestHelper.userErrors.first?["message"] as? String
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { errorMessage in
                            self.shopifyAPI.signUp(with: "user@mail.com", firstName: nil, lastName: nil, password: "password", phone: nil) { (success, error) in
                                expect(success) == false
                                expect(error?.errorMessage) == errorMessage
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
            }
        }
        
        describe("when login called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
                    
                    self.shopifyAPI.login(with: "user@mail.com", password: "password") { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                    
                    self.logout()
                }
            }
            
            context("if error occured") {
                context("because of user error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.login(with: "user@mail.com", password: "password") { (success, error) in
                            expect(success) == false
                            expect(error?.errorMessage) == ShopifyAPITestHelper.userErrors.first?["message"] as? String
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { errorMessage in
                            self.shopifyAPI.login(with: "user@mail.com", password: "password") { (success, error) in
                                expect(success) == false
                                expect(error?.errorMessage) == errorMessage
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
            }
        }
        
        describe("when is logged in called") {
            beforeEach {
                self.login()
            }
            
            context("if user default hasn't status") {
                it("needs to return false") {
                    UserDefaults.standard.set(nil, forKey: SessionData.loggedInStatus)
                    
                    let status = self.shopifyAPI.isLoggedIn()
                    
                    expect(status) == false
                }
            }
            
            context("if key chain has correct data") {
                it("needs to return value of date's expiration") {
                    let date = Date(timeIntervalSinceNow: 1000)
                    let dateString = String(describing: date.timeIntervalSinceNow)
                    let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
                    keyChain.set(dateString, forKey: SessionData.expiryDate)
                    
                    let status = self.shopifyAPI.isLoggedIn()
                    
                    expect(status) == true
                }
            }
            
            context("if key chain has incorrect data") {
                it("needs to return false") {
                    let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
                    keyChain.delete(SessionData.accessToken)
                    
                    let status = self.shopifyAPI.isLoggedIn()
                    
                    expect(status) == false
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when logout called") {
            it("should return success") {
                self.login()
                
                self.shopifyAPI.logout() { (success, error) in
                    expect(success) == true
                    expect(error).to(beNil())
                }
                
                self.logout()
            }
        }
        
        describe("when reset password called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerRecover": ["userErrors": []]])

                    self.shopifyAPI.resetPassword(with: "user@mail.com") { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.resetPassword(with: "user@mail.com") { (success, error) in
                            expect(success) == false
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get customer called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["customer": ShopifyAPITestHelper.customer])
                    
                    self.shopifyAPI.getCustomer() { (customer, error) in
                        expect(customer?.email) == ShopifyAPITestHelper.customer["email"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.getCustomer() { (customer, error) in
                                expect(customer).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.getCustomer() { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when update customer info called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.updateCustomer(with: "user@mail.com", firstName: nil, lastName: nil, phone: nil) { (customer, error) in
                        expect(customer?.firstName) == ShopifyAPITestHelper.customer["firstName"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updateCustomer(with: "user@mail.com", firstName: nil, lastName: nil, phone: nil) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error?.errorMessage) == ShopifyAPITestHelper.userErrors.first?["message"] as? String
                        }
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.updateCustomer(with: "user@mail.com", firstName: nil, lastName: nil, phone: nil) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when update customer promo called") {
            beforeEach {
                self.login()
            }

            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.updateCustomer(with: true) { (customer, error) in
                        expect(customer?.promo) == ShopifyAPITestHelper.customer["acceptsMarketing"] as? Bool
                        expect(error).to(beNil())
                    }
                }
            }

            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updateCustomer(with: true) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error?.errorMessage) == ShopifyAPITestHelper.userErrors.first?["message"] as? String
                        }
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()

                        self.shopifyAPI.updateCustomer(with: true) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }

            afterEach {
                self.logout()
            }
        }

        describe("when update customer password called") {
            beforeEach {
                self.login()
            }

            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
                    
                    self.shopifyAPI.updateCustomer(with: "password") { (customer, error) in
                        expect(customer?.email) == ShopifyAPITestHelper.customer["email"] as? String
                        expect(error).to(beNil())
                    }
                }
            }

            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updateCustomer(with: "password") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error?.errorMessage) == ShopifyAPITestHelper.userErrors.first?["message"] as? String
                        }
                    }
                }

                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.updateCustomer(with: "password") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }

            afterEach {
                self.logout()
            }
        }

        describe("when add customer address called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressCreate": ["customerAddress": ShopifyAPITestHelper.mailingAddress]])
                    
                    self.shopifyAPI.addCustomerAddress(with: Address()) { (addressId, error) in
                        expect(addressId) == ShopifyAPITestHelper.mailingAddress["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressCreate": ["customerAddress": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.addCustomerAddress(with: Address()) { (addressId, error) in
                                expect(addressId).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.addCustomerAddress(with: Address()) { (addressId, error) in
                            expect(addressId).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when update customer address called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressUpdate": ["customerAddress": ShopifyAPITestHelper.mailingAddress]])
                    
                    self.shopifyAPI.updateCustomerAddress(with: Address()) { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressUpdate": ["customerAddress": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.updateCustomerAddress(with: Address()) { (success, error) in
                                expect(success) == false
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.updateCustomerAddress(with: Address()) { (success, error) in
                            expect(success) == false
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when update customer default address called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerDefaultAddressUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.updateCustomerDefaultAddress(with: "addressId") { (customer, error) in
                        expect(customer?.email) == ShopifyAPITestHelper.customer["email"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerDefaultAddressUpdate": ["customer": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.updateCustomerDefaultAddress(with: "addressId") { (customer, error) in
                                expect(customer).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.updateCustomerDefaultAddress(with: "addressId") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
        
        describe("when delete customer address called") {
            beforeEach {
                self.login()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressDelete": ["deletedCustomerAddressId": "addressId"]])
                    
                    self.shopifyAPI.deleteCustomerAddress(with: "addressId") { (success, error) in
                        expect(success) == true
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressDelete": ["deletedCustomerAddressId": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.deleteCustomerAddress(with: "addressId") { (success, error) in
                                expect(success) == false
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.logout()
                        
                        self.shopifyAPI.deleteCustomerAddress(with: "addressId") { (success, error) in
                            expect(success) == false
                            expect(error is ContentError) == true
                        }
                    }
                }
            }
            
            afterEach {
                self.logout()
            }
        }
    }
}

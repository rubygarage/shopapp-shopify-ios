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
        
        let userErrorMessage = ShopifyAPITestHelper.userErrors.first?["message"] as? String ?? ""
        
        describe("when sign up called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerCreate": ["customer": ShopifyAPITestHelper.customer]])
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
                    
                    self.shopifyAPI.signUp(firstName: "First", lastName: "Last", email: "user@mail.com", password: "password", phone: "+1011231231") { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because of user error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerCreate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.signUp(firstName: "First", lastName: "Last", email: "user@mail.com", password: "password", phone: "+11011231231") { (_, error) in
                            expect(error) == ShopAppError.nonCritical(message: userErrorMessage)
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.signUp(firstName: "First", lastName: "Last", email: "user@mail.com", password: "password", phone: "+11011231231") { (_, error) in
                                expect(error) == ShopAppError.critical
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
                    
                    self.shopifyAPI.signIn(email: "user@mail.com", password: "password") { (_, error) in
                        expect(error).to(beNil())
                    }
                    
                    self.signOut()
                }
            }
            
            context("if error occured") {
                context("because of user error") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.signIn(email: "user@mail.com", password: "password") { (_, error) in
                            expect(error) == ShopAppError.nonCritical(message: userErrorMessage)
                        }
                    }
                }
                
                context("because of content error") {
                    it("should return error") {
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.signIn(email: "user@mail.com", password: "password") { (_, error) in
                                expect(error) == ShopAppError.critical
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
            }
        }
        
        describe("when is logged in called") {
            beforeEach {
                self.signIn()
            }
            
            context("if user default hasn't status") {
                it("needs to return false") {
                    UserDefaults.standard.set(nil, forKey: SessionData.loggedInStatus)
                    
                    self.shopifyAPI.isSignedIn(callback: { (status, _) in
                        expect(status) == false
                    })
                }
            }
            
            context("if key chain has correct data") {
                it("needs to return value of date's expiration") {
                    let date = Date(timeIntervalSinceNow: 1000)
                    let dateString = String(describing: date.timeIntervalSinceNow)
                    let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
                    keyChain.set(dateString, forKey: SessionData.expiryDate)
                    
                    self.shopifyAPI.isSignedIn(callback: { (status, _) in
                        expect(status) == true
                    })
                }
            }
            
            context("if key chain has incorrect data") {
                it("needs to return false") {
                    let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
                    keyChain.delete(SessionData.accessToken)
                    
                    self.shopifyAPI.isSignedIn(callback: { (status, _) in
                        expect(status) == false
                    })
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when logout called") {
            it("should return success") {
                self.signIn()
                
                self.shopifyAPI.signOut() { (_, error) in
                    expect(error).to(beNil())
                }
                
                self.signOut()
            }
        }
        
        describe("when reset password called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerRecover": ["userErrors": []]])

                    self.shopifyAPI.resetPassword(email: "user@mail.com") { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { _ in
                        self.shopifyAPI.resetPassword(email: "user@mail.com") { (_, error) in
                            expect(error) == ShopAppError.critical
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get customer called") {
            beforeEach {
                self.signIn()
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
                        self.signOut()
                        
                        self.shopifyAPI.getCustomer() { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when update customer info called") {
            beforeEach {
                self.signIn()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.updateCustomer(firstName: "First", lastName: "Last", phone: "+11011231231") { (customer, error) in
                        expect(customer?.firstName) == ShopifyAPITestHelper.customer["firstName"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updateCustomer(firstName: "First", lastName: "Last", phone: "+11011231231") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.nonCritical(message: userErrorMessage)
                        }
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.updateCustomer(firstName: "First", lastName: "Last", phone: "+11011231231") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when update customer promo called") {
            beforeEach {
                self.signIn()
            }

            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.updateCustomerSettings(isAcceptMarketing: true) { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }

            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updateCustomerSettings(isAcceptMarketing: true) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.nonCritical(message: userErrorMessage)
                        }
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()

                        self.shopifyAPI.updateCustomerSettings(isAcceptMarketing: true) { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }

            afterEach {
                self.signOut()
            }
        }

        describe("when update customer password called") {
            beforeEach {
                self.signIn()
            }

            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
                    
                    self.shopifyAPI.updatePassword(password: "password") { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }

            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerUpdate": ["customer": NSNull(), "userErrors": ShopifyAPITestHelper.userErrors]])
                        
                        self.shopifyAPI.updatePassword(password: "password") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.nonCritical(message: userErrorMessage)
                        }
                    }
                }

                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.updatePassword(password: "password") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }

            afterEach {
                self.signOut()
            }
        }

        describe("when add customer address called") {
            beforeEach {
                self.signIn()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressCreate": ["customerAddress": ShopifyAPITestHelper.mailingAddress]])
                    
                    self.shopifyAPI.addCustomerAddress(address: TestHelper.fullAddress) { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressCreate": ["customerAddress": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.addCustomerAddress(address: TestHelper.fullAddress) { (addressId, error) in
                                expect(addressId).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.addCustomerAddress(address: TestHelper.fullAddress) { (addressId, error) in
                            expect(addressId).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when update customer address called") {
            beforeEach {
                self.signIn()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressUpdate": ["customerAddress": ShopifyAPITestHelper.mailingAddress]])
                    
                    self.shopifyAPI.updateCustomerAddress(address: TestHelper.fullAddress) { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressUpdate": ["customerAddress": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.updateCustomerAddress(address: TestHelper.fullAddress) { (_, error) in
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.updateCustomerAddress(address: TestHelper.fullAddress) { (_, error) in
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when update customer default address called") {
            beforeEach {
                self.signIn()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerDefaultAddressUpdate": ["customer": ShopifyAPITestHelper.customer]])
                    
                    self.shopifyAPI.setDefaultShippingAddress(id: "addressId") { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerDefaultAddressUpdate": ["customer": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.setDefaultShippingAddress(id: "addressId") { (customer, error) in
                                expect(customer).to(beNil())
                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.setDefaultShippingAddress(id: "addressId") { (customer, error) in
                            expect(customer).to(beNil())
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
        
        describe("when delete customer address called") {
            beforeEach {
                self.signIn()
            }
            
            context("if success") {
                it("should return customer") {
                    self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressDelete": ["deletedCustomerAddressId": "addressId"]])
                    
                    self.shopifyAPI.deleteCustomerAddress(id: "addressId") { (_, error) in
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                context("because got error from server") {
                    it("should return error") {
                        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAddressDelete": ["deletedCustomerAddressId": NSNull()]])
                        
                        let errorExpectation: ErrorExpectation = { _ in
                            self.shopifyAPI.deleteCustomerAddress(id: "addressId") { (_, error) in                                expect(error).toNot(beNil())
                            }
                        }
                        
                        self.expectError(in: errorExpectation)
                    }
                }
                
                context("because user's status is not login") {
                    it("should return error") {
                        self.signOut()
                        
                        self.shopifyAPI.deleteCustomerAddress(id: "addressId") { (_, error) in
                            expect(error) == ShopAppError.critical
                        }
                    }
                }
            }
            
            afterEach {
                self.signOut()
            }
        }
    }
}

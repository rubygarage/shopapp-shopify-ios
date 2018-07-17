//
//  ShopifyAPISetupSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 6/15/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore
import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPISetupSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when setup provider called") {
            var productVariantId: String!
            
            context("if success") {
                context("and cart has items") {
                    context("and cart hasn't unavailable items") {
                        it("shouldn't remove cart item") {
                            productVariantId = "VariantIdentifier"
                            let productVariants = [ShopifyAPITestHelper.variant]
                            self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["nodes": productVariants])
                            
                            waitUntil(timeout: 10) { done in
                                CoreStore.perform(asynchronous: { transaction in
                                    self.generateCartProduct(productVariantId: productVariantId, transaction: transaction)
                                }, completion: { _ in
                                    self.shopifyAPI.setupProvider(callback: { (_, error) in
                                        expect(error).to(beNil())
                                        
                                        let items = CoreStore.fetchAll(From<CartProductEntity>())
                                        expect(items?.count) == 1
                                        
                                        done()
                                    })
                                })
                            }
                        }
                    }
                    
                    context("and cart has unavailable items") {
                        it("should remove cart item") {
                            productVariantId = "id"
                            let productVariants = [ShopifyAPITestHelper.variant]
                            self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["nodes": productVariants])
                            
                            waitUntil(timeout: 10) { done in
                                CoreStore.perform(asynchronous: { transaction in
                                    self.generateCartProduct(productVariantId: productVariantId, transaction: transaction)
                                }, completion: { _ in
                                    self.shopifyAPI.setupProvider(callback: { (_, error) in
                                        expect(error).to(beNil())
                                        
                                        let items = CoreStore.fetchAll(From<CartProductEntity>())
                                        expect(items?.count) == 0
                                        
                                        done()
                                    })
                                })
                            }
                        }
                    }
                }
                
                context("or cart hasn't items") {
                    it("shouldn't do any changes in cart") {
                        waitUntil(timeout: 10) { done in
                            self.shopifyAPI.setupProvider(callback: { (_, error) in
                                expect(error).to(beNil())
                                
                                let items = CoreStore.fetchAll(From<CartProductEntity>())
                                expect(items?.count) == 0
                                
                                done()
                            })
                        }
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    productVariantId = "id"
                    waitUntil(timeout: 10) { done in
                        CoreStore.perform(asynchronous: { transaction in
                            self.generateCartProduct(productVariantId: productVariantId, transaction: transaction)
                        }, completion: { _ in
                            let errorExpectation: ErrorExpectation = { errorMessage in
                                self.shopifyAPI.setupProvider(callback: { (_, error) in
                                    expect(error).toNot(beNil())
                                    
                                    let items = CoreStore.fetchAll(From<CartProductEntity>())
                                    expect(items?.count) == 1
                                    
                                    done()
                                })
                            }
                            
                            self.expectError(in: errorExpectation)
                        })
                    }
                }
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<CartProductEntity>())
                transaction.deleteAll(From<ProductVariantEntity>())
            })
        }
    }
    
    // MARK: - Additional
    
    private func generateCartProduct(productVariantId: String, transaction: AsynchronousDataTransaction) {
        let productVariant = transaction.create(Into<ProductVariantEntity>())
        productVariant.id.value = productVariantId
        
        let cartProduct = transaction.create(Into<CartProductEntity>())
        cartProduct.id.value = "productId"
        cartProduct.title.value = "title"
        cartProduct.productVariant.value = productVariant
        cartProduct.currency.value = "currency"
        cartProduct.quantity.value = 5
    }
}

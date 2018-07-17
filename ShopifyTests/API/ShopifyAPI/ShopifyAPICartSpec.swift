//
//  ShopifyAPICartSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 6/6/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPICartSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when cart product list should be get") {
            it("needs to fetch and return all adapted entities") {
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        transaction.create(Into<CartProductEntity>())
                    }, completion: { _ in
                        self.shopifyAPI.getCartProducts() { (result, _) in
                            expect(result?.count) == 1
                            
                            done()
                        }
                    })
                }
            }
        }
        
        describe("when cart product should be add") {
            var cartProduct: CartProduct!
            
            beforeEach {
                cartProduct = TestHelper.cartProductWithQuantityOne
            }
            
            context("if there is no entity with identifier") {
                it("needs to create new entity") {
                    waitUntil(timeout: 10) { done in
                        self.shopifyAPI.addCartProduct(cartProduct: cartProduct) { (_, _) in
                            var numberOfEntities: Int?
                            
                            CoreStore.perform(asynchronous: { transaction in
                                numberOfEntities = transaction.fetchCount(From<CartProductEntity>())
                            }, completion: { _ in
                                expect(numberOfEntities) == 1
                                
                                done()
                            })
                        }
                    }
                }
            }
            
            context("if there is one entity with identifier") {
                it("needs to fetch entity and update them quantity") {
                    waitUntil(timeout: 10) { done in
                        self.shopifyAPI.addCartProduct(cartProduct: cartProduct) { (_, _) in
                            self.shopifyAPI.addCartProduct(cartProduct: cartProduct) { (_, _) in
                                let entities = CoreStore.fetchAll(From<CartProductEntity>())
                                
                                expect(entities?.count) == 1
                                expect(entities?.first?.quantity.value) == 2
                                
                                done()
                            }
                        }
                    }
                }
            }
        }
        
        describe("when cart product should be delete") {
            it("needs to delete selected entity") {
                let cartItemId = "id"
                
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        let entity = transaction.create(Into<CartProductEntity>())
                        entity.productVariant.value = transaction.create(Into<ProductVariantEntity>())
                        entity.productVariant.value?.id.value = cartItemId
                    }, completion: { _ in
                        self.shopifyAPI.deleteCartProduct(cartItemId: cartItemId) { (_, _) in
                            var numberOfEntities: Int?
                            
                            CoreStore.perform(asynchronous: { transaction in
                                numberOfEntities = transaction.fetchCount(From<CartProductEntity>())
                            }, completion: { _ in
                                expect(numberOfEntities) == 0
                                
                                done()
                            })
                        }
                    })
                }
            }
        }
        
        describe("when cart products by ids should be delete") {
            it("should delete selected entities") {
                let productVariantId = "id1"
                let productVariantToDeleteId = "id2"
                let allProductVariantIds = [productVariantId, productVariantToDeleteId]
                
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        allProductVariantIds.forEach({
                            let entity = transaction.create(Into<CartProductEntity>())
                            entity.productVariant.value = transaction.create(Into<ProductVariantEntity>())
                            entity.productVariant.value?.id.value = $0
                        })
                    }, completion: { _ in
                        self.shopifyAPI.deleteCartProducts(productVariantIds: [productVariantToDeleteId]) { (_, _) in
                            var numberOfEntities: Int?
                            var existProductVariantIds: [String]?

                            CoreStore.perform(asynchronous: { transaction in
                                numberOfEntities = transaction.fetchCount(From<CartProductEntity>())
                                let all = transaction.fetchAll(From<CartProductEntity>())
                                existProductVariantIds = all?.map({ ($0.productVariant.value?.id.value)! })
                            }, completion: { _ in
                                expect(numberOfEntities) == 1
                                expect(existProductVariantIds).to(equal([productVariantId]))

                                done()
                            })
                        }
                    })
                }
            }
        }
        
        describe("when all cart products should be delete") {
            it("needs to delete all entities") {
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        _ = transaction.create(Into<CartProductEntity>())
                        _ = transaction.create(Into<CartProductEntity>())
                    }, completion: { _ in
                        self.shopifyAPI.deleteAllCartProducts() { (_, _) in
                            var numberOfEntities: Int?
                            
                            CoreStore.perform(asynchronous: { transaction in
                                numberOfEntities = transaction.fetchCount(From<CartProductEntity>())
                            }, completion: { _ in
                                expect(numberOfEntities) == 0
                                
                                done()
                            })
                        }
                    })
                }
            }
        }
        
        describe("when cart product's quantity should be change") {
            it("needs to change value") {
                let cartItemId = "id"
                let quantity = 2
                
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        let entity = transaction.create(Into<CartProductEntity>())
                        entity.productVariant.value = transaction.create(Into<ProductVariantEntity>())
                        entity.productVariant.value?.id.value = cartItemId
                        entity.quantity.value = 1
                    }, completion: { _ in
                        self.shopifyAPI.changeCartProductQuantity(cartItemId: cartItemId, quantity: quantity) { (_, _) in
                            let entity = CoreStore.fetchOne(From<CartProductEntity>())
                            
                            expect(entity?.quantity.value) == Int64(quantity)
                            
                            done()
                        }
                    })
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
}

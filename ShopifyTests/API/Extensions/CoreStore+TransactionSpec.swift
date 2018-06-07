//
//  CoreStore+TransactionSpec.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 3/30/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class CoreStore_TransactionSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when extention's func used") {
            context("if entity was created") {
                it("needs to return fetched entity") {
                    let id = "id"
                    let predicate = NSPredicate(format: "productId == %@", id)
                    
                    waitUntil(timeout: 10) { done in
                        CoreStore.perform(asynchronous: { transaction in
                            let entity = transaction.create(Into<CartProductEntity>())
                            entity.productId.value = "productId"

                            let entityNew: CartProductEntity? = transaction.fetchOrCreate(predicate: predicate)
                            entityNew?.productId.value = id
                        }, completion: { _ in
                            let entity = CoreStore.fetchOne(From<CartProductEntity>(), Where(predicate))
                            expect(entity?.productId.value) == id

                            done()
                        })
                    }
                }
            }
            
            context("if entity wasn't created") {
                it("needs to create a new entity and return it") {
                    let id = "id"
                    let predicate = NSPredicate(format: "productId == %@", id)
                    
                    waitUntil(timeout: 10) { done in
                        CoreStore.perform(asynchronous: { transaction in
                            let entity: CartProductEntity? = transaction.fetchOrCreate(predicate: predicate)
                            entity?.productId.value = id
                        }, completion: { _ in
                            let entity = CoreStore.fetchOne(From<CartProductEntity>(), Where(predicate))
                            expect(entity?.productId.value) == id
                            
                            done()
                        })
                    }
                }
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<CartProductEntity>())
            })
        }
    }
}

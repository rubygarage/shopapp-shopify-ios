//
//  CartProductEntityUpdateServiceSpec.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 3/29/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class CartProductEntityUpdateServiceSpec: QuickSpec {
    override func spec() {
        beforeEach {            
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when update service used") {
            it("needs to update entity with item") {                
                let productVariant = ProductVariant()
                productVariant.id = "id"
                
                let item = CartProduct()
                item.productId = "id"
                item.productTitle = "title"
                item.quantity = 5
                item.currency = "currency"
                item.productVariant = productVariant
                
                waitUntil(timeout: 10) { done in
                    CoreStore.perform(asynchronous: { transaction in
                        let entity = transaction.create(Into<CartProductEntity>())
                        CartProductEntityUpdateService.update(entity, with: item, transaction: transaction)
                    }, completion: { _ in
                        let entity = CoreStore.fetchOne(From<CartProductEntity>())
                        
                        expect(entity?.productId.value) == item.productId
                        expect(entity?.productTitle.value) == item.productTitle
                        expect(entity?.quantity.value) == Int64(item.quantity)
                        expect(entity?.currency.value) == item.currency
                        expect(entity?.productVariant.value?.id.value) == productVariant.id
                        
                        done()
                    })
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


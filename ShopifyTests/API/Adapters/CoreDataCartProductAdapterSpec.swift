//
//  CoreDataCartProductAdapterSpec.swift
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

class CoreDataCartProductAdapterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when adapter used") {
            it("needs to return nil if item is nil") {
                let object = CoreDataCartProductAdapter.adapt(item: nil)
                
                expect(object).to(beNil())
            }
            
            it("needs to adapt entity item to model object") {
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let productVariant = transaction.create(Into<ProductVariantEntity>())
                    productVariant.id.value = "id"
                    
                    let cartProduct = transaction.create(Into<CartProductEntity>())
                    cartProduct.id.value = "productId"
                    cartProduct.title.value = "title"
                    cartProduct.productVariant.value = productVariant
                    cartProduct.currency.value = "currency"
                    cartProduct.quantity.value = 5
                })
                
                let item = CoreStore.fetchOne(From<CartProductEntity>())
                let object = CoreDataCartProductAdapter.adapt(item: item)!
                
                expect(object.id) == item?.productVariant.value?.id.value
                expect(object.title) == item?.title.value
                expect(object.productVariant?.id) == item?.productVariant.value?.id.value
                expect(object.currency) == item?.currency.value
                expect(object.quantity) == Int(item?.quantity.value ?? 0)
            }
            
            it("needs to adapt model objects th other one") {
                let productQuantity = 5
                let product = TestHelper.productWithoutImages
                let productVariant = TestHelper.productVariantWithoutSelectedOptions
                
                let object = CartProductAdapter.adapt(product: product, productQuantity: productQuantity, variant: productVariant)!
                
                expect(object.id) == product.id
                expect(object.title) == product.title
                expect(object.productVariant?.id) == productVariant.id
                expect(object.currency) == product.currency
                expect(object.quantity) == productQuantity
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<ProductVariantEntity>())
                transaction.deleteAll(From<CartProductEntity>())
            })
        }
    }
}

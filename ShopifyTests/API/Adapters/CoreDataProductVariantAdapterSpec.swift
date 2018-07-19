//
//  CoreDataProductVariantAdapterSpec.swift
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

class CoreDataProductVariantAdapterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when adapter used") {
            it("needs to adapt entity item to model object") {
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let image = transaction.create(Into<ImageEntity>())
                    image.id.value = "id"
                    
                    let variantOption = transaction.create(Into<VariantOptionEntity>())
                    variantOption.name.value = "name"
                    
                    let productVariant = transaction.create(Into<ProductVariantEntity>())
                    productVariant.id.value = "id"
                    productVariant.price.value = 5.5
                    productVariant.title.value = "title"
                    productVariant.isAvailable.value = true
                    productVariant.image.value = image
                    productVariant.productId.value = "productId"
                    productVariant.selectedOptions.value.insert(variantOption)
                })

                let item = CoreStore.fetchOne(From<ProductVariantEntity>())
                let object = CoreDataProductVariantAdapter.adapt(item: item)!
      
                expect(object.id) == item?.id.value
                expect(object.price) == item?.price.value.decimalValue
                expect(object.title) == item?.title.value
                expect(object.isAvailable) == item?.isAvailable.value
                expect(object.image?.id) == item?.image.value?.id.value
                expect(object.productId) == item?.productId.value
                expect(object.selectedOptions.first?.name) == item?.selectedOptions.value.first?.name.value
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<ImageEntity>())
                transaction.deleteAll(From<VariantOptionEntity>())
                transaction.deleteAll(From<ProductVariantEntity>())
            })
        }
    }
}

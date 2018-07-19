//
//  CoreDataVariantOptionAdapterSpec.swift
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

class CoreDataVariantOptionAdapterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when adapter used") {
            it("needs to return nil if item is nil") {
                let object = CoreDataVariantOptionAdapter.adapt(item: nil)
                
                expect(object).to(beNil())
            }
            
            it("needs to return empty model object if item has empty values") {
                _ = try? CoreStore.perform(synchronous: { transaction in
                    transaction.create(Into<VariantOptionEntity>())
                })
                
                let item = CoreStore.fetchOne(From<VariantOptionEntity>())
                let object = CoreDataVariantOptionAdapter.adapt(item: item)!
                
                expect(object.name) == ""
                expect(object.value) == ""
            }
            
            it("needs to adapt entity item to model object") {
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let item = transaction.create(Into<VariantOptionEntity>())
                    item.name.value = "name"
                    item.value.value = "value"
                })
                
                let item = CoreStore.fetchOne(From<VariantOptionEntity>())
                let object = CoreDataVariantOptionAdapter.adapt(item: item)!
                
                expect(object.name) == item?.name.value
                expect(object.value) == item?.value.value
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<VariantOptionEntity>())
            })
        }
    }
}

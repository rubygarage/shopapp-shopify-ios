//
//  VariantOptionEntityUpdateServiceSpec.swift
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

class VariantOptionEntityUpdateServiceSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when update service used") {
            it("needs to update entity with item") {
                let item = TestHelper.variantOption
                
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let entity = transaction.create(Into<VariantOptionEntity>())
                    VariantOptionEntityUpdateService.update(entity, with: item)
                })
                
                let entity = CoreStore.fetchOne(From<VariantOptionEntity>())

                expect(entity?.name.value) == item.name
                expect(entity?.value.value) == item.value
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<VariantOptionEntity>())
            })
        }
    }
}

//
//  CoreDataImageAdapterSpec.swift
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

class CoreDataImageAdapterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when adapter used") {
            it("needs to adapt entity item to model object") {
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let item = transaction.create(Into<ImageEntity>())
                    item.id.value = "id"
                    item.src.value = "src"
                })
                
                let item = CoreStore.fetchOne(From<ImageEntity>())
                
                let object = CoreDataImageAdapter.adapt(item: item)!
                
                expect(object.id) == item?.id.value
                expect(object.src) == item?.src.value
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<ImageEntity>())
            })
        }
    }
}

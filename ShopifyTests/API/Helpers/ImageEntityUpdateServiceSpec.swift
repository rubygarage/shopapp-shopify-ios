//
//  ImageEntityUpdateServiceSpec.swift
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

class ImageEntityUpdateServiceSpec: QuickSpec {
    override func spec() {
        beforeEach {
            DataBaseConfig.setup(inMemoryStore: true)
        }
        
        describe("when update service used") {
            it("needs to update entity with item") {
                let item = Image()
                item.id = "id"
                item.src = "src"
                item.imageDescription = "imageDescription"
                
                _ = try? CoreStore.perform(synchronous: { transaction in
                    let entity = transaction.create(Into<ImageEntity>())
                    ImageEntityUpdateService.update(entity, with: item)
                })
                
                let entity = CoreStore.fetchOne(From<ImageEntity>())
                
                expect(entity?.id.value) == item.id
                expect(entity?.src.value) == item.src
                expect(entity?.imageDescription.value) == item.imageDescription
            }
        }
        
        afterEach {
            _ = try? CoreStore.perform(synchronous: { transaction in
                transaction.deleteAll(From<ImageEntity>())
            })
        }
    }
}

//
//  ShopifyProductVariantAdapterSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/5/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyProductVariantAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            var item: Storefront.ProductVariant!
            
            beforeEach {
                item = try! Storefront.ProductVariant(fields: ShopifyAdapterTestHelper.variant)
            }
            
            it("needs to adapt storefront item to model object") {
                let object = ShopifyProductVariantAdapter.adapt(item: item)!
                
                self.compare(object, with: item)
            }
        }
    }
    
    private func compare(_ object: ProductVariant, with item: Storefront.ProductVariant) {
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.price) == item.price
        expect(object.isAvailable) == item.availableForSale
        expect(object.image?.id) == item.image?.id?.rawValue
        expect(object.selectedOptions.first?.name) == item.selectedOptions.first?.name
        expect(object.productId) == item.product.id.rawValue
    }
}

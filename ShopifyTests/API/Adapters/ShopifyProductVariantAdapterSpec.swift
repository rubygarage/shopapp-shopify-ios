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
            var id: GraphQL.ID!
            var image: Storefront.Image!
            
            beforeEach {
                item = try! Storefront.ProductVariant(fields: ShopifyAdapterTestHelper.variant)
                id = GraphQL.ID(rawValue: "id")
                image = try! Storefront.Image(fields: ShopifyAdapterTestHelper.image)
            }
            
            context("if needs full variant") {
                it("needs to adapt storefront item to model object") {
                    let object = ShopifyProductVariantAdapter.adapt(item: item, productId: id, productImage: image)!
                    
                    self.compare(object, with: item, id: id)
                }
            }
            
            context("if needs short variant") {
                it("needs to adapt storefront item to model object") {
                    let object = ShopifyProductVariantAdapter.adapt(item: item, productId: id, productImage: image, isShortVariant: true)!
                    
                    self.compare(object, with: item, id: id, isShortVariant: true)
                }
            }
        }
    }
    
    private func compare(_ object: ProductVariant, with item: Storefront.ProductVariant, id: GraphQL.ID, isShortVariant: Bool = false) {
        guard !isShortVariant else {
            expect(object.price) == item.price
            
            return
        }
        
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.price) == item.price
        expect(object.available) == item.availableForSale
        expect(object.image?.id) == item.image?.id?.rawValue
        expect(object.selectedOptions?.first?.name) == item.selectedOptions.first?.name
        expect(object.productId) == id.rawValue
    }
}

//
//  ShopifyCategoryAdapterSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/4/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyCategoryAdapterSpec: QuickSpec {
    private let currencyValue = "Currency"
    
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Collection(fields: ShopifyAdapterTestHelper.collection)
                let object = ShopifyCategoryAdapter.adapt(item: item, currencyValue: self.currencyValue)!
                
                self.compare(object, with: item, isProductListNeeded: true)
                
                expect(object.additionalDescription) == item.descriptionHtml
            }
        }
        
        describe("when adapter used") {
            it("needs to adapt storefront edge to model object") {
                let edge = try! Storefront.CollectionEdge(fields: ShopifyAdapterTestHelper.collectionEdge)
                let object = ShopifyCategoryAdapter.adapt(item: edge, currencyValue: self.currencyValue)!
                
                self.compare(object, with: edge.node)
                
                expect(object.paginationValue as? String) == edge.cursor
            }
        }
    }
    
    private func compare(_ object: ShopApp_Gateway.Category, with item: Storefront.Collection, isProductListNeeded: Bool = false) {
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.categoryDescription) == item.description
        expect(object.image?.id) == item.image?.id?.rawValue
        expect(object.updatedAt) == item.updatedAt
        
        if isProductListNeeded {
            expect(object.products?.first?.currency) == self.currencyValue
        }
    }
}

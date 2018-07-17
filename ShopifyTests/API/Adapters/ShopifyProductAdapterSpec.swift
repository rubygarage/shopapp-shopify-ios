//
//  ShopifyProductAdapterSpec.swift
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

class ShopifyProductAdapterSpec: QuickSpec {
    private let currencyValue = "Currency"
    
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Product(fields: ShopifyAdapterTestHelper.product)
                let object = ShopifyProductAdapter.adapt(item: item, currency: self.currencyValue)
                
                self.compare(object, with: item)
            }
        }
        
        describe("when adapter used") {
            it("needs to adapt storefront edge to model object") {
                let edge = try! Storefront.ProductEdge(fields: ShopifyAdapterTestHelper.productEdges)
                let object = ShopifyProductAdapter.adapt(edgeItem: edge, currency: self.currencyValue)
                
                self.compare(object, with: edge.node)
                
                expect(object.paginationValue) == edge.cursor
            }
        }
    }
    
    private func compare(_ object: Product, with item: Storefront.Product) {
        let variantsPrices = item.variants.edges.map { $0.node.price }.sorted(by: { $0 < $1 })
        let hasAlternativePrice = variantsPrices.min() ?? 0.0 != variantsPrices.max() ?? 0.0
        
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.productDescription) == item.description
        expect(object.currency) == currencyValue
        expect(object.discount).to(beNil())
        expect(object.type) == item.productType
        expect(object.images.first?.id) == item.images.edges.first?.node.id?.rawValue
        expect(object.options.first?.id) == item.options.first?.id.rawValue
        expect(object.price) == variantsPrices.first
        expect(object.hasAlternativePrice) == hasAlternativePrice
        expect(object.variants.first?.id) == item.variants.edges.first?.node.id.rawValue
    }
}

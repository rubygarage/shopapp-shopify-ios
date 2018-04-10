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
                let object = ShopifyProductAdapter.adapt(item: item, currencyValue: self.currencyValue)!
                
                self.compare(object, with: item)
            }
        }
        
        describe("when adapter used") {
            it("needs to adapt storefront edge to model object") {
                let edge = try! Storefront.ProductEdge(fields: ShopifyAdapterTestHelper.productEdges)
                let object = ShopifyProductAdapter.adapt(item: edge, currencyValue: self.currencyValue)!
                
                self.compare(object, with: edge.node, isShortVariant: true)
                
                expect(object.paginationValue) == edge.cursor
            }
        }
    }
    
    private func compare(_ object: Product, with item: Storefront.Product, isShortVariant: Bool = false) {
        expect(object.id) == item.id.rawValue
        expect(object.title) == item.title
        expect(object.productDescription) == item.description
        expect(object.currency) == currencyValue
        expect(object.discount) == ""
        expect(object.type) == item.productType
        expect(object.vendor) == item.vendor
        expect(object.createdAt) == item.createdAt
        expect(object.updatedAt) == item.updatedAt
        expect(object.tags) == item.tags
        expect(object.additionalDescription) == item.descriptionHtml
        expect(object.images?.first?.id) == item.images.edges.first?.node.id?.rawValue
        expect(object.options?.first?.id) == item.options.first?.id.rawValue
        
        if !isShortVariant {
            expect(object.variants?.first?.id) == item.variants.edges.first?.node.id.rawValue
            
            if let options = object.options, options.count == 1 && options.first?.values?.count == 1 {
                expect(object.variants?.first?.title) == ""
            }
        } else {
            let variantsPrices = item.variants.edges.map { $0.node.price }.sorted(by: { $0 < $1 })
            let hasAlternativePrice = variantsPrices.min() ?? 0.0 != variantsPrices.max() ?? 0.0
            
            expect(object.price) == variantsPrices.first
            expect(object.hasAlternativePrice) == hasAlternativePrice
        }
    }
}

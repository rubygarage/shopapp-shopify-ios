//
//  ShopifyOrderAdapterSpec.swift
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

class ShopifyOrderAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Order(fields: ShopifyAdapterTestHelper.order)
                let object = ShopifyOrderAdapter.adapt(item: item)!
                
                self.compare(object, with: item)
            }
        }
        
        describe("when adapter used") {
            it("needs to adapt storefront edge to model object") {
                let edge = try! Storefront.OrderEdge(fields: ShopifyAdapterTestHelper.orderEdge)
                let object = ShopifyOrderAdapter.adapt(item: edge)!
                
                self.compare(object, with: edge.node, isShortVariant: true)
                
                expect(object.paginationValue) == edge.cursor
            }
        }
    }
    
    private func compare(_ object: Order, with item: Storefront.Order, isShortVariant: Bool = false) {
        expect(object.id) == item.id.rawValue
        expect(object.currencyCode) == item.currencyCode.rawValue
        expect(object.number) == Int(item.orderNumber)
        expect(object.createdAt) == item.processedAt
        expect(object.totalPrice) == item.totalPrice
        expect(object.items?.first?.title) == item.lineItems.edges.first?.node.title
        
        if !isShortVariant {
            expect(object.shippingAddress?.id) == item.shippingAddress?.id.rawValue
            expect(object.subtotalPrice) == item.subtotalPrice
            expect(object.totalShippingPrice) == item.totalShippingPrice
        }
    }
}

//
//  ShopifyImageAdapterSpec.swift
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

class ShopifyImageAdapterSpec: QuickSpec {
    override func spec() {
        describe("when adapter used") {
            it("needs to adapt storefront item to model object") {
                let item = try! Storefront.Image(fields: ShopifyAdapterTestHelper.image)
                let object = ShopifyImageAdapter.adapt(item: item)!
                
                expect(object.id) == item.id?.rawValue
                expect(object.src) == item.originalSrc.absoluteString
                expect(object.imageDescription) == item.altText
            }
        }
    }
}

//
//  ShopifyAPIShopSpec.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPIShopSpec: QuickSpec {
    override func spec() {
        var clientMock: GraphClientMock!
        var shopifyAPI: ShopifyAPI!
        
        beforeEach {
            let apiKey = "api key"
            let shopDomain = "shop domain"
            let adminApiKey = "admin api key"
            let adminPassword = "admin password"
            let applePayMerchantId = "apple pay merchant id"
            
            clientMock = GraphClientMock(shopDomain: shopDomain, apiKey: apiKey)
            
            shopifyAPI = ShopifyAPI(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId, client: clientMock)
        }
        
        describe("when get shop info called") {
            context("if success") {
                beforeEach {
                    clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ShopifyAPITestHelper.shop])
                }
                
                it("should return success") {
                    shopifyAPI.getShopInfo() { (shop, error) in
                        expect(shop?.name) == ShopifyAPITestHelper.shop["name"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                var errorMessage: String!
                
                beforeEach {
                    errorMessage = "Error message"
                    clientMock.returnedError = Graph.QueryError.request(error: RepoError(with: errorMessage))
                }
                
                it("should return error") {
                    shopifyAPI.getShopInfo() { (shop, error) in
                        expect(shop).to(beNil())
                        expect(error?.errorMessage) == errorMessage
                    }
                }
            }
        }
    }
}

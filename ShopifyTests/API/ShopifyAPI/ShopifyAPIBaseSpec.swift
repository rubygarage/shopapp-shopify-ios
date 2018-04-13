//
//  ShopifyAPIBaseSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/12/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

typealias ErrorExpectation = (String) -> Void

class ShopifyAPIBaseSpec: QuickSpec {
    private let apiKey = "api key"
    private let shopDomain = "nameofshop.myshopify.com"
    private let adminApiKey = "admin api key"
    private let adminPassword = "admin password"
    private let applePayMerchantId = "apple pay merchant id"
    
    var clientMock: GraphClientMock!
    var shopifyAPI: ShopifyAPI!
    
    override func spec() {
        beforeEach {
            self.clientMock = GraphClientMock(shopDomain: self.shopDomain, apiKey: self.apiKey)
            
            self.shopifyAPI = ShopifyAPI(apiKey: self.apiKey, shopDomain: self.shopDomain, adminApiKey: self.adminApiKey, adminPassword: self.adminPassword, applePayMerchantId: self.applePayMerchantId, client: self.clientMock)
        }
    }
    
    func expectError(in errorExpectation: ErrorExpectation) {
        let message = "Error message"
        let error = RepoError(with: message)
        self.clientMock.returnedError = Graph.QueryError.request(error: error)
        
        errorExpectation(message)
    }
}

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
    
    var shopifyAPI: ShopifyAPI!
    var adminApiMock: AdminAPIMock!
    var clientMock: GraphClientMock!
    var cardClientMock: CardClientMock!
    
    override func spec() {
        beforeEach {
            self.clientMock = GraphClientMock(shopDomain: self.shopDomain, apiKey: self.apiKey)
            self.adminApiMock = AdminAPIMock(apiKey: self.apiKey, password: self.adminPassword, shopDomain: self.shopDomain)
            self.cardClientMock = CardClientMock()
            
            self.shopifyAPI = ShopifyAPI(apiKey: self.apiKey, shopDomain: self.shopDomain, adminApiKey: self.adminApiKey, adminPassword: self.adminPassword, applePayMerchantId: self.applePayMerchantId, client: self.clientMock, adminApi: self.adminApiMock, cardClient: self.cardClientMock)
        }
    }
    
    func generateQueryError(with message: String = "") -> Graph.QueryError {
        let error = RepoError(with: message)
        return Graph.QueryError.request(error: error)
    }
    
    func expectError(in errorExpectation: ErrorExpectation) {
        let message = "Error message"
        let error = generateQueryError(with: message)
        self.clientMock.returnedError = error
        
        errorExpectation(message)
    }
    
    func login() {
        self.clientMock.returnedMutationResponse = try! Storefront.Mutation(fields: ["customerAccessTokenCreate": ["customerAccessToken": ShopifyAPITestHelper.accessToken]])
        self.shopifyAPI.login(with: "user@mail.com", password: "password") { (_, _) in }
    }
    
    func logout() {
        self.shopifyAPI.logout() { (_, _) in }
    }
}

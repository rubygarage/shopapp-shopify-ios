//
//  AdminAPISpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class AdminAPISpec: QuickSpec {
    override func spec() {
        let key = "key"
        let password = "password"
        let domain = "test.myshopify.com"
        
        var api: AdminAPI!
        
        beforeEach {
            api = AdminAPI.init(apiKey: key, password: password, shopDomain: domain)
        }
        
        describe("when ") {
            it("needs to ") {
                
            }
        }
    }
}

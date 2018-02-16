//
//  Repository.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 10/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopClient_Gateway

public class ShopifyRepository: Repository {
    
    let api: API

    init(apiKey: String, shopDomain: String, adminApiKey: String, adminPassword: String, applePayMerchantId: String?) {
        self.api = ShopifyAPI(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId)
    }
}

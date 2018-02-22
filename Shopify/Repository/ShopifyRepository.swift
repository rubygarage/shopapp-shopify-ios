//
//  Repository.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 10/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

public class ShopifyRepository: Repository {
    let api: API

    /**
     Initializer for Shopify repository.

     - Parameter apiKey: API Key
     - Parameter shopDomain: Domain of shop
     - Parameter adminApiKey: API key for Admin API for sync available countries and states for shipping
     - Parameter adminPassword: Password for Admin API
     - Parameter applePayMerchantId: Merchant ID for Apple Pay. Optional.
     */
    public init(apiKey: String, shopDomain: String, adminApiKey: String, adminPassword: String, applePayMerchantId: String?) {
        self.api = ShopifyAPI(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId)
    }

    /**
        Initializer for Shopify repository which reads properties from Shopify.plist.

        Put file Shopify.plist into main application. File format:

        ```
        <dict>
            <key>apiKey</key>
            <string>PUT YOUR API KEY</string>
            <key>shopDomain</key>
            <string>PUT YOUR SHOP DOMAIN</string>
            <key>adminApiKey</key>
            <string>PUT YOUR ADMIN API KEY</string>
            <key>adminPassword</key>
            <string>PUT YOUR ADMIN PASSWORD</string>
            <key>applePayMerchantId</key>
            <string>PUT YOUR APPLE PAY MERCHANT ID IF YOU WANT USE APPLE PAY</string>
        </dict>
        ```
    */
    public convenience init?() {
        guard let fileUrl = Bundle.main.url(forResource: "Shopify", withExtension: "plist") else {
            return nil
        }

        guard let data = try? Data(contentsOf: fileUrl) else {
            return nil
        }

        guard let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }

        if let apiKey = config!["apiKey"] as? String,
            let shopDomain = config!["shopDomain"] as? String,
            let adminApiKey = config!["adminApiKey"] as? String,
            let adminPassword = config!["adminPassword"] as? String {

            let applePayMerchantId = config!["applePayMerchantId"] as? String

            self.init(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId)
        } else {
            return nil
        }
    }
}

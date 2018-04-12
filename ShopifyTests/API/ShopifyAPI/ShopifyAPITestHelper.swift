//
//  ShopifyAPITestHelper.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/11/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Foundation

struct ShopifyAPITestHelper {
    static var shopPolicy: [String: Any] {
        return ["title": "Title",
                "body": "Body",
                "url": "www.google.com"]
    }
    
    static var shop: [String: Any] {
        return ["name": "Name",
                "description": "Description",
                "privacyPolicy": shopPolicy,
                "refundPolicy": shopPolicy,
                "termsOfService": shopPolicy]
    }
}

class TestTask: Task {
    func resume() {}
    func cancel() {}
}

//
//  AdminAPIMock.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/16/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import ShopApp_Gateway

@testable import Shopify

class AdminAPIMock: AdminAPI {
    var returnedResponse: [Country]?
    var returnedError: ShopAppError?
    
    override func getCountries(callback: @escaping ApiCallback<[Country]>) {
        callback(returnedResponse, returnedError)
    }
}

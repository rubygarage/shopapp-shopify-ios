//
//  GraphClientMock.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import ShopApp_Gateway

@testable import MobileBuySDK
@testable import Shopify

class GraphClientMock: Graph.Client {
    var returnedResponse: Storefront.QueryRoot?
    var returnedError: Graph.QueryError?
    
    override func queryGraphWith(_ query: Storefront.QueryRootQuery, cachePolicy: Graph.CachePolicy?, retryHandler: Graph.RetryHandler<Storefront.QueryRoot>?, completionHandler: @escaping Graph.QueryCompletion) -> Task {
        completionHandler(returnedResponse, returnedError)

        return TestTask()
    }
}


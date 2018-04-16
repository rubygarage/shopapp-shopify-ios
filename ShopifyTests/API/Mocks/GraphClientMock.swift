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
    private var returnedValues: [Any] = []
    
    var returnedResponse: Storefront.QueryRoot? {
        didSet {
            if let response = returnedResponse {
                returnedValues.insert(response, at: 0)
            }
        }
    }
    var returnedMutationResponse: Storefront.Mutation? {
        didSet {
            if let response = returnedMutationResponse {
                returnedValues.insert(response, at: 0)
            }
        }
    }
    var returnedError: Graph.QueryError? {
        didSet {
            if let error = returnedError {
                returnedValues.insert(error, at: 0)
            }
        }
    }
    
    override func queryGraphWith(_ query: Storefront.QueryRootQuery, cachePolicy: Graph.CachePolicy?, retryHandler: Graph.RetryHandler<Storefront.QueryRoot>?, completionHandler: @escaping Graph.QueryCompletion) -> Task {
        let returnedValue = returnedValues.popLast()
        if let response = returnedValue as? Storefront.QueryRoot {
            completionHandler(response, nil)
        } else if let error = returnedValue as? Graph.QueryError {
            completionHandler(nil, error)
        }

        return TestTask()
    }
    
    override func mutateGraphWith(_ mutation: Storefront.MutationQuery, retryHandler: Graph.RetryHandler<Storefront.Mutation>?, completionHandler: @escaping Graph.MutationCompletion) -> Task {
        let returnedValue = returnedValues.popLast()
        if let response = returnedValue as? Storefront.Mutation {
            completionHandler(response, nil)
        } else if let error = returnedValue as? Graph.QueryError {
            completionHandler(nil, error)
        }
        
        return TestTask()
    }
}

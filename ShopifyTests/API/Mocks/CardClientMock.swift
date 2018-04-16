//
//  CardClientMock.swift
//  ShopifyTests
//
//  Created by Evgeniy Antonov on 4/16/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

@testable import MobileBuySDK
@testable import Shopify

class CardClientMock: Card.Client {
    private var returnedValues: [Any] = []
    
    var returnedResponse: String? {
        didSet {
            if let response = returnedResponse {
                returnedValues.insert(response, at: 0)
            }
        }
    }
    var returnedError: Error? {
        didSet {
            if let error = returnedError {
                returnedValues.insert(error, at: 0)
            }
        }
    }
    
    override func vault(_ creditCard: Card.CreditCard, to url: URL, completion: @escaping Card.VaultCompletion) -> Task {
        let returnedValue = returnedValues.popLast()
        if let response = returnedValue as? String {
            completion(response, nil)
        } else if let error = returnedValue as? Error {
            completion(nil, error)
        }
        
        return TestTask()
    }
}

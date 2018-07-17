//
//  BaseAPISpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire
import Nimble
import OHHTTPStubs
import Quick
import ShopApp_Gateway

@testable import Shopify

class BaseAPISpec: QuickSpec {
    override func spec() {
        let host = "httpbin.org"
        let url = URL(string: kHttpsUrlPrefix + host)!
        let request = URLRequest(url: url)
        
        var api: BaseAPI!
        
        beforeEach {
            api = BaseAPI()
        }
        
        describe("when response has value but not json") {
            it("needs to return error") {
                stub(condition: isHost(host)) { _ in
                    return OHHTTPStubsResponse()
                }
                
                waitUntil { done in
                    api.execute(request) { (response, error) in
                        expect(response).to(beNil())
                        expect(error) == ShopAppError.content(isNetworkError: false)
                        
                        done()
                    }
                }
            }
        }
        
        describe("when response has error with message") {
            it("needs to return error") {
                let message = "error"
                
                stub(condition: isHost(host)) { _ in
                    let jsonObject = ["message": message]

                    
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 100, headers: nil)
                }
                
                waitUntil { done in
                    api.execute(request) { (response, error) in
                        expect(response).to(beNil())
                        expect(error) == ShopAppError.nonCritical(message: message)
                        
                        done()
                    }
                }
            }
        }
        
        describe("when has error without message") {
            it("needs to return error") {
                stub(condition: isHost(host)) { _ in
                    let jsonObject = ["key": "value"]
                    
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 100, headers: nil)
                }
                
                waitUntil { done in
                    api.execute(request) { (response, error) in
                        expect(response).to(beNil())
                        expect(error) == ShopAppError.content(isNetworkError: false)
                        
                        done()
                    }
                }
            }
        }
        
        describe("when has value as json") {
            it("needs to return json") {
                let key = "key"
                let value = "value"
                
                stub(condition: isHost(host)) { _ in
                    let jsonObject = [key: value]
                    
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
                }
                
                waitUntil { done in
                    api.execute(request) { (response, error) in
                        expect(response?[key] as? String) == value
                        expect(error).to(beNil())
                        
                        done()
                    }
                }
            }
        }
        
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }
    }
}

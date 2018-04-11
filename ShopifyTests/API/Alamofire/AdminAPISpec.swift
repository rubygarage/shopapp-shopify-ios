//
//  AdminAPISpec.swift
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

class AdminAPISpec: QuickSpec {
    override func spec() {
        let domain = "nameofshop.myshopify.com"
        
        var api: AdminAPI!
        
        beforeEach {
            api = AdminAPI(apiKey: "key", password: "password", shopDomain: domain)
        }
        
        describe("when user gets countries but server returns error") {
            it("needs to return error") {
                stub(condition: isHost(domain)) { _ in
                    return OHHTTPStubsResponse()
                }
                
                waitUntil { done in
                    api.getCountries() { (response, error) in
                        expect(response).to(beNil())
                        expect(error).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
        
        describe("when user gets countries and server returns them") {
            it("needs to return countries from server") {
                let jsonObject = self.countries()
                
                stub(condition: isHost(domain)) { _ in
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
                }
                
                waitUntil { done in
                    api.getCountries() { (response, error) in
                        expect(response?.count) == (jsonObject["countries"] as? [ApiJson])?.count
                        expect(error).to(beNil())
                        
                        done()
                    }
                }
            }
        }
        
        describe("when user gets countries and server returns them with special value") {
            it("needs to return countries from json file") {
                let jsonObject = self.countries(withSpecial: true)
                
                stub(condition: isHost(domain)) { _ in
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
                }
                
                waitUntil { done in
                    api.getCountries() { (response, error) in
                        expect(response?.isEmpty) == false
                        expect(error).to(beNil())
                        
                        done()
                    }
                }
            }
        }
        
        describe("when user gets countries but server returns not valid data") {
            it("needs to return error") {
                stub(condition: isHost(domain)) { _ in
                    let jsonObject = ["key": "value"]
                    
                    return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
                }
                
                waitUntil { done in
                    api.getCountries() { (response, error) in
                        expect(response).to(beNil())
                        expect(error is ContentError) == true
                        
                        done()
                    }
                }
            }
        }
        
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }
    }
    
    private func countries(withSpecial hasSpecial: Bool = false) -> ApiJson {
        let firstProvince = ["name": "First province"]
        let secondProvince = ["name": "Second province"]
        let provinces = [firstProvince, secondProvince]
        let countyWithProvinces = ["name": "County with provinces", "provinces": provinces] as [String : Any]
        let countyWithoutProvinces = ["name": hasSpecial ? "Rest of World" : "County without provinces"]
        let countries = [countyWithProvinces, countyWithoutProvinces]
        let jsonObject = ["countries": countries]
        
        return jsonObject as ApiJson
    }
}

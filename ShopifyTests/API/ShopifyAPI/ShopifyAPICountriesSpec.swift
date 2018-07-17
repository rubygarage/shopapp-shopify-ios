//
//  ShopifyAPICountriesSpec.swift
//  ShopifyTests
//
//  Created by Mykola Voronin on 6/14/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

class ShopifyAPICountriesSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()

        describe("when get countries called") {
            context("if success") {
                it("should return success response") {
                    let countries: [Country] = []
                    self.adminApiMock.returnedResponse = countries

                    self.shopifyAPI.getCountries() { (countries, error) in
                        expect(countries) === countries
                        expect(error).to(beNil())
                    }
                }
            }

            context("if error occured") {
                it("should return error") {
                    let errorMessage = "Error message"
                    self.adminApiMock.returnedError = ShopAppError.nonCritical(message: errorMessage)
                    
                    self.shopifyAPI.getCountries() { (countries, error) in
                        expect(countries).to(beNil())
                        expect(error) == self.adminApiMock.returnedError
                    }
                }
            }
        }
    }
}

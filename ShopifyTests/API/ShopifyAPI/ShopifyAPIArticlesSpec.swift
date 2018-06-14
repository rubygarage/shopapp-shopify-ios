//
//  ShopifyAPIArticlesSpec.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/12/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MobileBuySDK
import Nimble
import Quick
import ShopApp_Gateway

@testable import Shopify

class ShopifyAPIArticlespSpec: ShopifyAPIBaseSpec {
    override func spec() {
        super.spec()
        
        describe("when get article list called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["shop": ["articles": ShopifyAPITestHelper.articles]])
                    
                    self.shopifyAPI.getArticles(perPage: 10, paginationValue: nil, sortBy: nil) { (articles, error) in
                        expect(articles?.first?.id) == ShopifyAPITestHelper.article["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getArticles(perPage: 10, paginationValue: nil, sortBy: nil) { (articles, error) in
                            expect(articles?.isEmpty) == true
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get article called") {
            context("if success response") {
                context("and node exist") {
                    it("should return success") {
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.article])
                        
                        self.shopifyAPI.getArticle(id: "id") { (response, error) in
                            expect(response?.article.id) == ShopifyAPITestHelper.article["id"] as? String
                            expect(error).to(beNil())
                        }
                    }
                }
                
                context("or node does't exist") {
                    it("should return error with CriticalError type") {
                        self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": NSNull()])
                        
                        self.shopifyAPI.getArticle(id: "id") { (response, error) in
                            expect(response).to(beNil())
                            expect(error is CriticalError) == true
                        }
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getArticle(id: "id") { (response, error) in
                            expect(response).to(beNil())
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
            
            context("if response and error are nil") {
                it("should return eror with ContentError type") {
                    self.clientMock.clear()
                    
                    self.shopifyAPI.getArticle(id: "id") { (response, error) in
                        expect(response).to(beNil())
                        expect(error is ContentError) == true
                    }
                }
            }
        }
    }
}

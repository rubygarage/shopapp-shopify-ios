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
                    
                    self.shopifyAPI.getArticleList(perPage: 10, paginationValue: nil, sortBy: nil, reverse: false) { (articles, error) in
                        expect(articles?.first?.id) == ShopifyAPITestHelper.article["id"] as? String
                        expect(error).to(beNil())
                    }
                }
            }
            
            context("if error occured") {
                it("should return error") {
                    let errorExpectation: ErrorExpectation = { errorMessage in
                        self.shopifyAPI.getArticleList(perPage: 10, paginationValue: nil, sortBy: nil, reverse: false) { (articles, error) in
                            expect(articles?.isEmpty) == true
                            expect(error?.errorMessage) == errorMessage
                        }
                    }
                    
                    self.expectError(in: errorExpectation)
                }
            }
        }
        
        describe("when get article called") {
            context("if success") {
                it("should return success") {
                    self.clientMock.returnedResponse = try! Storefront.QueryRoot(fields: ["node": ShopifyAPITestHelper.article])
                    
                    self.shopifyAPI.getArticle(id: "id") { (response, error) in
                        expect(response?.article.id) == ShopifyAPITestHelper.article["id"] as? String
                        expect(error).to(beNil())
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
        }
    }
}

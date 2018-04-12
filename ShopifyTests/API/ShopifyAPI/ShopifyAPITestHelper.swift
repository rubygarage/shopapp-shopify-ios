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
    
    static var author: [String: Any] {
        return ["firstName": "First",
                "lastName": "Last",
                "name": "Name",
                "email": "user@mail.com",
                "bio": "Bio"]
    }
    
    static var tags: [String] {
        return ["First tag",
                "Second tag"]
        
    }
    
    static var blog: [String: Any] {
        return ["id": "BlogIdentifier",
                "title": "Title"]
    }
    
    static var image: [String: Any] {
        return ["id": "ImageIdentifier",
                "src": "Source",
                "altText": "Text"]
    }
    
    static var article: [String: Any] {
        return ["id": "ArticleIdentifier",
                "title": "Title",
                "content": "Content",
                "contentHtml": "Html",
                "author": author,
                "tags": tags,
                "blog": blog,
                "publishedAt": "2018-01-01T12:15:25+01:00",
                "url": "www.google.com",
                "image": image,
                "__typename": "Article"]
    }
    
    static var articleEdges: [[String: Any]] {
        return [["node": article,
                 "cursor": "Cursor"]]
    }
    
    static var articles: [String: Any] {
        return ["edges": articleEdges]
    }
}

//
//  ShopifyAdapterTestHelper.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 4/4/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation

struct ShopifyAdapterTestHelper {
    static var mailingAddress: [String: Any] {
        return ["id": "Identifier",
                "firstName": "First",
                "lastName": "Last",
                "address1": "Address 1",
                "address2": "Address 2",
                "city": "City",
                "country": "Country",
                "province": "Province",
                "zip": "Zip",
                "phone": "Phone"]
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
        return ["id": "Identifier",
                "title": "Title"]
    }
    
    static var image: [String: Any] {
        return ["id": "Identifier",
                "src": "Source",
                "altText": "Text"]
    }
    
    static var article: [String: Any] {
        return ["id": "Identifier",
                "title": "Title",
                "content": "Content",
                "contentHtml": "Html",
                "author": author,
                "tags": tags,
                "blog": blog,
                "publishedAt": "2018-01-01T12:15:25+01:00",
                "url": "www.google.com",
                "image": image]
    }
    
    static var articleEdge: [String: Any] {
        return ["node": article,
                "cursor": "Cursor"]
    }

    static var values: [String] {
        return ["Value"]
    }
    
    static var option: [String: Any] {
        return ["id": "Identifier",
                "name": "Name",
                "values": values]
    }
    
    static var options: [[String: Any]] {
        return [option]
    }
    
    static var selectedOption: [String: Any] {
        return ["name": "Name",
                "value": "Value"]
    }
    
    static var selectedOptions: [[String: Any]] {
        return [selectedOption]
    }
    
    static var variant: [String: Any] {
        return ["id": "Identifier",
                "title": "Title",
                "price": "5",
                "availableForSale": true,
                "image": image,
                "selectedOptions": selectedOptions]
    }
    
    static var variantsEdges: [[String: Any]] {
        return [["node": variant,
                 "cursor": "Cursor"]]
    }
    
    static var variants: [String: Any] {
        return ["edges": variantsEdges]
    }

    static var imagesEdges: [[String: Any]] {
        return [["node": image,
                 "cursor": "Cursor"]]
    }
    
    static var images: [String: Any] {
        return ["edges": imagesEdges]
    }

    static var product: [String: Any] {
        return ["id": "Identifier",
                "title": "Title",
                "description": "Description",
                "productType": "Type",
                "vendor": "Vendor",
                "createdAt": "2018-01-01T12:15:25+01:00",
                "updatedAt": "2018-01-01T12:15:25+01:00",
                "tags": tags,
                "descriptionHtml": "Html",
                "images": images,
                "variants": variants,
                "options": options]
    }
    
    static var productEdges: [String: Any] {
        return ["node": product,
                "cursor": "Cursor"]
    }
    
    static var productsEdges: [[String: Any]] {
        return [["node": product,
                 "cursor": "Cursor"]]
    }
    
    static var products: [String: Any] {
        return ["edges": productsEdges]
    }
    
    static var collection: [String: Any] {
        return ["id": "Identifier",
                "title": "Title",
                "description": "Description",
                "image": image,
                "updatedAt": "2018-01-01T12:15:25+01:00",
                "descriptionHtml": "Html",
                "products": products]
    }
    
    static var collectionEdge: [String: Any] {
        return ["node": collection,
                "cursor": "Cursor"]
    }

    static var shippingRates: [[String: Any]] {
        return [shippingRate]
    }
    
    static var availableShippingRates: [String: Any] {
        return ["shippingRates": shippingRates]
    }
    
    static var checkoutLineItem: [String: Any] {
        return ["id": "Identifier",
                "variant": variant,
                "quantity": 5]
    }
    
    static var checkoutLineItemsEdges: [[String: Any]] {
        return [["node": checkoutLineItem,
                 "cursor": "Cursor"]]
    }
    
    static var checkoutLineItems: [String: Any] {
        return ["edges": checkoutLineItemsEdges]
    }
    
    static var shippingRate: [String: Any] {
        return ["title": "Title",
                "price": "5",
                "handle": "Handle"]
    }
    
    static var checkout: [String: Any] {
        return ["id": "Identifier",
                "webUrl": "www.google.com",
                "currencyCode": "Currency",
                "subtotalPrice": "5",
                "totalPrice": "5",
                "shippingLine": shippingRate,
                "shippingAddress": mailingAddress,
                "lineItems": checkoutLineItems,
                "availableShippingRates": availableShippingRates]
    }
    
    static var province: [String: Any] {
        return ["name": "Name"]
    }
    
    static var provinces: [[String: Any]] {
        return [province]
    }
    
    static var country: [String: Any] {
        return ["name": "Name", "provinces": provinces]
    }

    static var addressesEdges: [[String: Any]] {
        return [["node": mailingAddress,
                 "cursor": "Cursor"]]
    }
    
    static var addresses: [String: Any] {
        return ["edges": addressesEdges]
    }
    
    static var customer: [String: Any] {
        return ["email": "user@mail.com",
                "firstName": "First",
                "lastName": "Last",
                "phone": "Phone",
                "acceptsMarketing": true,
                "defaultAddress": mailingAddress,
                "addresses": addresses]
    }

    static var orderLineItem: [String: Any] {
        return ["title": "Title",
                "variant": variant,
                "quantity": 5]
    }
    
    static var orderLineItemsEdges: [[String: Any]] {
        return [["node": orderLineItem,
                 "cursor": "Cursor"]]
    }
    
    static var orderLineItems: [String: Any] {
        return ["edges": orderLineItemsEdges]
    }
    
    static var order: [String: Any] {
        return ["id": "Identifier",
                "currencyCode": "Currency",
                "orderNumber": 5,
                "processedAt": "2018-01-01T12:15:25+01:00",
                "totalPrice": "5",
                "lineItems": orderLineItems,
                "shippingAddress": mailingAddress,
                "subtotalPrice": "5",
                "totalShippingPrice": "5"]
    }
    
    static var orderEdge: [String: Any] {
        return ["node": order,
                "cursor": "Cursor"]
    }
    
    static var shopPolicy: [String: Any] {
        return ["title": "Title",
                "body": "Body",
                "url": "www.google.com"]
    }
    
    
    
    
    
    
    
    
    static var error: [String: Any] {
        return ["message": "Message"]
    }
    
    static var shop: [String: Any] {
        return ["name": "Name",
                "description": "Description",
                "privacyPolicy": shopPolicy,
                "refundPolicy": shopPolicy,
                "termsOfService": shopPolicy]
    }
}

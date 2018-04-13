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
    
    static var productsEdges: [[String: Any]] {
        return [["node": product,
                 "cursor": "Cursor"]]
    }
    
    static var products: [String: Any] {
        return ["edges": productsEdges]
    }
    
    static var product: [String: Any] {
        return ["id": "ProductIdentifier",
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
                "options": options,
                "__typename": "Product"]
    }
    
    static var collection: [String: Any] {
        return ["id": "CollectionIdentifier",
                "title": "Title",
                "description": "Description",
                "image": image,
                "updatedAt": "2018-01-01T12:15:25+01:00",
                "descriptionHtml": "Html",
                "products": products,
                "__typename": "Collection"]
    }
    
    static var collectionEdge: [String: Any] {
        return ["node": collection,
                "cursor": "Cursor"]
    }

    static var checkout: [String: Any] {
        return ["id": "CheckoutIdentifier",
                "webUrl": "www.google.com",
                "currencyCode": "Currency",
                "subtotalPrice": "5",
                "totalPrice": "5",
                "shippingLine": shippingRate,
                "shippingAddress": mailingAddress,
                "lineItems": checkoutLineItems,
                "availableShippingRates": availableShippingRates,
                "__typename": "Checkout"]
    }
    
    static var checkoutCreateUserErrors: [[String: Any]] {
        return [["message": "Error message"]]
    }
    
    static var mailingAddress: [String: Any] {
        return ["id": "MailingAddressIdentifier",
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
    
    static var values: [String] {
        return ["Value"]
    }
    
    static var option: [String: Any] {
        return ["id": "OptionIdentifier",
                "name": "Name",
                "values": values]
    }
    
    static var options: [[String: Any]] {
        return [option]
    }
    
    static var images: [String: Any] {
        return ["edges": imagesEdges]
    }
    
    static var imagesEdges: [[String: Any]] {
        return [["node": image,
                 "cursor": "Cursor"]]
    }
    
    static var image: [String: Any] {
        return ["id": "ImageIdentifier",
                "src": "Source",
                "altText": "Text"]
    }
    
    static var variants: [String: Any] {
        return ["edges": variantsEdges]
    }
    
    static var variantsEdges: [[String: Any]] {
        return [["node": variant,
                 "cursor": "Cursor"]]
    }

    static var selectedOption: [String: Any] {
        return ["name": "Name",
                "value": "Value"]
    }
    
    static var selectedOptions: [[String: Any]] {
        return [selectedOption]
    }
    
    static var variantImage: [String: Any] {
        return ["id": "VariantImageIdentifier",
                "src": "Source",
                "altText": "Text"]
    }
    
    static var variantProduct: [String: Any] {
        return ["id": "VariantProductIdentifier",
                "images": images,
                "options": options]
    }

    static var checkoutLineItem: [String: Any] {
        return ["id": "CheckoutLineItemIdentifier",
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
    
    static var availableShippingRates: [String: Any] {
        return ["shippingRates": shippingRates]
    }
    
    static var shippingRates: [[String: Any]] {
        return [shippingRate]
    }
    
    static var shippingRate: [String: Any] {
        return ["title": "Title",
                "price": "5",
                "handle": "Handle"]
    }
    
    static var variant: [String: Any] {
        return ["id": "VariantIdentifier",
                "title": "Title",
                "price": "5",
                "availableForSale": true,
                "image": variantImage,
                "selectedOptions": selectedOptions,
                "product": variantProduct]
    }
    
    static var paymentSetting: [String: Any] {
        return ["currencyCode": "Currency"]
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
        return ["id": "OrderIdentifier",
                "currencyCode": "Currency",
                "orderNumber": 5,
                "processedAt": "2018-01-01T12:15:25+01:00",
                "totalPrice": "5",
                "lineItems": orderLineItems,
                "shippingAddress": mailingAddress,
                "subtotalPrice": "5",
                "totalShippingPrice": "5",
                "__typename": "Order"]
    }
    
    static var orderEdges: [[String: Any]] {
        return [["node": order,
                "cursor": "Cursor"]]
    }
    
    static var orders: [String: Any] {
        return ["edges": orderEdges]
    }
    
    static var accessToken: [String: Any] {
        return ["accessToken": "AccessToken",
                "expiresAt": "2018-01-01T12:15:25+01:00"]
    }
    
    static var customerAccessToken: [String: Any] {
        return ["customerAccessToken": accessToken]
    }
    
    static var customerAccessTokenCreate: [String: Any] {
        return ["customerAccessTokenCreate": customerAccessToken]
    }

    static var variantImage: [String: Any] {
        return ["id": "VariantImageIdentifier",
                "src": "Source",
                "altText": "Text"]
    }
    
    static var selectedOptions: [[String: Any]] {
        return [selectedOption]
    }
    
    static var selectedOption: [String: Any] {
        return ["name": "Name",
                "value": "Value"]
    }
    
    static var variantProduct: [String: Any] {
        return ["id": "VariantProductIdentifier",
                "images": images,
                "options": options]
    }
    
    static var imagesEdges: [[String: Any]] {
        return [["node": image,
                 "cursor": "Cursor"]]
    }
    
    static var images: [String: Any] {
        return ["edges": imagesEdges]
    }
    
    static var option: [String: Any] {
        return ["id": "OptionIdentifier",
                "name": "Name",
                "values": values]
    }
    
    static var options: [[String: Any]] {
        return [option]
    }
    
    static var values: [String] {
        return ["Value"]
    }
    
    static var paymentSettings: [String: Any] {
           return ["currencyCode": "USD"]
    }
}

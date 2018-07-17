//
//  TestHelper.swift
//  ShopifyTests
//
//  Created by Radyslav Krechet on 7/17/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation
import ShopApp_Gateway

@testable import Shopify

struct TestHelper {
    static var fullAddress: Address {
        return Address(id: "id", firstName: "first", lastName: "last", street: "address", secondStreet: "second", city: "city", country: "country", state: "state", zip: "zip", phone: "phone")
    }
    
    static var card: Card {
        return Card(firstName: "first", lastName: "last", cardNumber: "4242424242424242", expireMonth: "month", expireYear: "year", verificationCode: "code")
    }
    
    static var cartProductWithQuantityOne: CartProduct {
        return CartProduct(id: "id", productVariant: productVariantWithoutSelectedOptions, title: "title", currency: "UAH", quantity: 1)
    }
    
    static var checkoutWithShippingAddress: Checkout {
        return Checkout(id: "id", subtotalPrice: Decimal(10), totalPrice: Decimal(15), currency: "UAH", shippingAddress: fullAddress, shippingRate: shippingRate, availableShippingRates: [shippingRate], lineItems: [LineItem()])
    }
    
    static var image: Image {
        return Image(id: "", src: "")
    }
    
    static var productWithoutImages: Product {
        return Product(id: "id", title: "title", productDescription: "description", price: Decimal(10), hasAlternativePrice: false, currency: "UAH", discount: "discount", images: [], type: "type", paginationValue: "pagination", variants: [productVariantWithoutSelectedOptions], options: [productOptionWithOneValue])
    }
    
    static var productOptionWithOneValue: ProductOption {
        return ProductOption(id: "id", name: "name", values: ["value"])
    }
    
    static var productVariantWithoutSelectedOptions: ProductVariant {
        return ProductVariant(id: "id", title: "title", price: Decimal(10), isAvailable: true, image: image, selectedOptions: [], productId: "productId")
    }
    
    static var productVariantWithSelectedOptions: ProductVariant {
        return ProductVariant(id: "id", title: "title", price: Decimal(10), isAvailable: true, image: image, selectedOptions: [variantOption, variantOption], productId: "productId")
    }
    
    static var shippingRate: ShippingRate {
        return ShippingRate(title: "title", price: Decimal(10), handle: "handle")
    }
    
    static var variantOption: VariantOption {
        return VariantOption(name: "name", value: "value")
    }
}

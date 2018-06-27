//
//  ShopifyCustomerAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 11/13/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyCustomerAdapter {
    static func adapt(item: Storefront.Customer?) -> Customer? {
        guard let item = item, let firstName = item.firstName, let lastName = item.lastName else {
            return nil
        }

        let email = item.email ?? ""
        let defaultAddress = ShopifyAddressAdapter.adapt(item: item.defaultAddress)
        let addresses = item.addresses.edges.flatMap { ShopifyAddressAdapter.adapt(item: $0.node) }

        return Customer(id: "", email: email, firstName: firstName, lastName: lastName, phone: item.phone, isAcceptsMarketing: item.acceptsMarketing, defaultAddress: defaultAddress, addresses: addresses)
    }
}

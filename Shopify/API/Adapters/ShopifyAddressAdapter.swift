//
//  ShopifyAddressAdapter.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 12/22/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import MobileBuySDK
import ShopApp_Gateway

struct ShopifyAddressAdapter {
    static func adapt(item: Storefront.MailingAddress?) -> Address? {
        guard let item = item, let firstName = item.firstName, let lastName = item.lastName, let street = item.address1, let city = item.city, let country = item.country, let zip = item.zip else {
            return nil
        }

        return Address(id: item.id.rawValue, firstName: firstName, lastName: lastName, street: street, secondStreet: item.address2, city: city, country: country, state: item.province, zip: zip, phone: item.phone)
    }
}


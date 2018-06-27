//
//  Country.swift
//  Shopify
//
//  Created by Radyslav Krechet on 2/9/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation
import ShopApp_Gateway

struct ShopifyCountryAdapter {
    private static let kShopifyCountryNameKey = "name"
    private static let kShopifyCountryProvincesKey = "provinces"

    static func adapt(item: ApiJson?) -> Country? {
        guard let item = item else {
            return nil
        }

        let name = item[kShopifyCountryNameKey] as? String ?? ""

        guard let provinces = item[kShopifyCountryProvincesKey] as? [ApiJson] else {
            return Country(id: "", name: name)
        }

        let states = provinces.flatMap { ShopifyStateAdapter.adapt(item: $0) }

        return Country(id: "", name: name, states: states)
    }
}

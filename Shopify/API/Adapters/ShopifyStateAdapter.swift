//
//  ShopifyStateAdapter.swift
//  Shopify
//
//  Created by Radyslav Krechet on 2/9/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import ShopApp_Gateway

struct ShopifyStateAdapter {
    private static let kShopifyStateNameKey = "name"

    static func adapt(item: ApiJson) -> State {
        let name = item[kShopifyStateNameKey] as? String ?? ""
        
        return State(id: "", name: name)
    }
}

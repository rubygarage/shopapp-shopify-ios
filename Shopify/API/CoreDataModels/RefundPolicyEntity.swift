//
//  RefundPolicyEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class RefundPolicyEntity: CoreStoreObject {
    let shop = Relationship.ToOne<ShopEntity>("shop")
}

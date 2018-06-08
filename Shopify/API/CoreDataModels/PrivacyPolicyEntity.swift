//
//  PrivacyPolicyEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class PrivacyPolicyEntity: CoreStoreObject {
    let shop = Relationship.ToOne<ShopEntity>("shop")
}

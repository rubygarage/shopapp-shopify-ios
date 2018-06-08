//
//  ShopEntity.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

class ShopEntity: CoreStoreObject {
    let currency = Value.Optional<String>("currency")
    let name = Value.Optional<String>("name")
    let shopDescription = Value.Optional<String>("shopDescription")
    
    let privacyPolicy = Relationship.ToOne<PrivacyPolicyEntity>("privacyPolicy", inverse: { $0.shop })
    let refundPolicy = Relationship.ToOne<RefundPolicyEntity>("refundPolicy", inverse: { $0.shop })
    let termsOfService = Relationship.ToOne<TermsOfServiceEntity>("termsOfService", inverse: { $0.shop })
}

//
//  CoreDataVariantOptionAdapter.swift
//  ShopApp
//
//  Created by Radyslav Krechet on 1/16/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import ShopApp_Gateway

struct CoreDataVariantOptionAdapter {
    static func adapt(item: VariantOptionEntity?) -> VariantOption? {
        guard let item = item else {
            return nil
        }

        let variantOption = VariantOption()
        variantOption.name = item.name.value ?? ""
        variantOption.value = item.value.value ?? ""
        
        return variantOption
    }
}

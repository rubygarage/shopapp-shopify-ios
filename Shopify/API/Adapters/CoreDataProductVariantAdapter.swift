//
//  CoreDataProductVariantAdapter.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/9/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

struct CoreDataProductVariantAdapter {
    static func adapt(item: ProductVariantEntity?) -> ProductVariant? {
        guard let item = item else {
            return nil
        }
        
        let productVariant = ProductVariant()
        productVariant.id = item.id.value
        productVariant.price = item.price.value.decimalValue
        productVariant.title = item.title.value
        productVariant.available = item.available.value ?? false
        productVariant.image = CoreDataImageAdapter.adapt(item: item.image.value)
        productVariant.productId = item.productId.value ?? ""
        
        productVariant.selectedOptions = item.selectedOptions.value.map {
            let option = VariantOption()
            option.name = $0.name.value ?? ""
            option.value = $0.value.value ?? ""
            
            return option
        }
        
        return productVariant
    }
}

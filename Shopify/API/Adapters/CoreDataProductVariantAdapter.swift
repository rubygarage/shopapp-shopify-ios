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
        
        let title = item.title.value ?? ""
        let isAvailable = item.isAvailable.value ?? false
        let image = CoreDataImageAdapter.adapt(item: item.image.value)
        let selectedOptions = item.selectedOptions.value.flatMap { CoreDataVariantOptionAdapter.adapt(item: $0) }
        let productId = item.productId.value ?? ""
        
        return ProductVariant(id: item.id.value, title: title, price: item.price.value.decimalValue, isAvailable: isAvailable, image: image, selectedOptions: selectedOptions, productId: productId)
    }
}

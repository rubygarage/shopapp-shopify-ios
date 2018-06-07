//
//  ImageEntityUpdateService.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/9/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

struct ImageEntityUpdateService {
    static func update(_ entity: ImageEntity?, with item: Image?) {
        guard let entity = entity else {
            return
        }
        
        entity.id.value = item?.id ?? ""
        entity.src.value = item?.src ?? ""
        entity.imageDescription.value = item?.imageDescription
    }
}

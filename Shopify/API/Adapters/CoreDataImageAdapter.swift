//
//  CoreDataImageAdapter.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/9/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

struct CoreDataImageAdapter {
    static func adapt(item: ImageEntity?) -> Image? {
        guard let item = item else {
            return nil
        }
        
        return Image(id: item.id.value , src: item.src.value)
    }
}

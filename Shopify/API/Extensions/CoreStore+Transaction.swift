//
//  CoreStore+Transaction.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/8/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import CoreStore

extension AsynchronousDataTransaction {
    func fetchOrCreate<T: DynamicObject>(predicate: NSPredicate) -> T {
        return fetchOne(From<T>(), Where(predicate)) ?? create(Into<T>())
    }
}

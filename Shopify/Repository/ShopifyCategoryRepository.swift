//
//  CategoryRepository.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 10/24/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import ShopApp_Gateway

extension ShopifyRepository: CategoryRepository {
    public func getCategoryList(perPage: Int, paginationValue: Any?, sortBy: SortingValue?, reverse: Bool, callback: @escaping RepoCallback<[ShopApp_Gateway.Category]>) {
        api.getCategoryList(perPage: perPage, paginationValue: paginationValue, sortBy: sortBy, reverse: reverse, callback: callback)
    }
    
    public func getCategoryDetails(id: String, perPage: Int, paginationValue: Any?, sortBy: SortingValue?, reverse: Bool, callback: @escaping RepoCallback<ShopApp_Gateway.Category>) {
        api.getCategoryDetails(id: id, perPage: perPage, paginationValue: paginationValue, sortBy: sortBy, reverse: reverse, callback: callback)
    }
}

//
//  BaseAPI.swift
//  Shopify
//
//  Created by Radyslav Krechet on 2/9/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire
import ShopApp_Gateway

typealias ApiJson = [String: AnyObject]

class BaseAPI {
    private let baseApiMessageKey = "message"
    
    private lazy var sessionManager: SessionManager = {
        return SessionManager(configuration: URLSessionConfiguration.default)
    }()
    
    func execute(_ request: URLRequestConvertible, callback: @escaping ApiCallback<ApiJson>) {
        let dataRequest = sessionManager.request(request)
        response(with: dataRequest, callback: callback)
    }
    
    private func response(with request: DataRequest, callback: @escaping ApiCallback<ApiJson>) {
        request.responseJSON { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            
            do {
                guard let json = response.value as? ApiJson else {
                    throw ShopAppError.content(isNetworkError: false)
                }
                
                guard response.error == nil, let statusCode = response.response?.statusCode, 200..<300 ~= statusCode else {
                    if let message = json[strongSelf.baseApiMessageKey] as? String {
                        throw ShopAppError.nonCritical(message: message)
                    } else {
                        throw ShopAppError.content(isNetworkError: false)
                    }
                }
                
                callback(json, nil)
            } catch {
                callback(nil, error as? ShopAppError)
            }
        }
    }
}

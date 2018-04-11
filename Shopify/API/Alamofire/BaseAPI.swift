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
    
    func execute(_ request: URLRequestConvertible, callback: @escaping RepoCallback<ApiJson>) {
        let dataRequest = sessionManager.request(request)
        response(with: dataRequest, callback: callback)
    }
    
    private func response(with request: DataRequest, callback: @escaping RepoCallback<ApiJson>) {
        request.responseJSON { [weak self] response in
            guard let strongSelf = self else {
                return
            }
            
            do {
                let statusCode = response.response?.statusCode ?? 500
                
                guard statusCode != 201 && statusCode != 204 else {
                    callback(nil, ContentError())
                    
                    return
                }
                
                guard let json = response.value as? [String: AnyObject] else {
                    throw ContentError()
                }
                
                guard response.error == nil, 200..<300 ~= statusCode else {
                    if let message = json[strongSelf.baseApiMessageKey] as? String {
                        throw ContentError(with: message)
                    } else {
                        throw ContentError()
                    }
                }
                
                callback(json, nil)
            } catch {
                callback(nil, error as? RepoError)
            }
        }
    }
}

//
//  ShopifyAPI.swift
//  Shopify
//
//  Created by Radyslav Krechet on 2/9/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire
import ShopApp_Gateway

class AdminAPI: BaseAPI {
    private let shopifyAdminCountriesKey = "countries"
    private let shopifyAdminCountriesRestOfWorldValue = "Rest of World"
    private let shopifyCountriesFileName = "Countries"
    private let shopifyCountriesFileType = "json"
    private let apiKey: String
    private let password: String
    private let shopDomain: String

    init(apiKey: String, password: String, shopDomain: String) {
        self.apiKey = apiKey
        self.password = password
        self.shopDomain = shopDomain
    }
    
    func getCountries(callback: @escaping ApiCallback<[Country]>) {
        let request = getUrlRequest()
        
        execute(request) { [weak self] (response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                callback(nil, error)
            } else if let response = response, let items = response[strongSelf.shopifyAdminCountriesKey] as? [ApiJson] {
                var countries = strongSelf.countries(with: items)
                
                guard countries.filter({ $0.name == strongSelf.shopifyAdminCountriesRestOfWorldValue }).first != nil else {
                    callback(countries, nil)
                    
                    return
                }

                let bundle = Bundle(for: type(of: strongSelf))
                let podPath = strongSelf.pathOfResource(withPodBundle: bundle)
                let testPath = bundle.path(forResource: strongSelf.shopifyCountriesFileName, ofType: strongSelf.shopifyCountriesFileType)

                guard podPath != nil || testPath != nil else {
                    callback(nil, ShopAppError.content(isNetworkError: false))
                    
                    return
                }
                
                do {
                    let path: String! = podPath != nil ? podPath : testPath
                    let url = URL(fileURLWithPath: path)
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    guard let items = json as? [ApiJson] else {
                        callback(nil, ShopAppError.content(isNetworkError: false))
                        
                        return
                    }
                    
                    countries = strongSelf.countries(with: items)
                    
                    callback(countries, nil)
                } catch {
                    callback(nil, ShopAppError.content(isNetworkError: false))
                }
            } else {
                callback(nil, ShopAppError.content(isNetworkError: false))
            }
        }
    }

    private func getBaseUrlString() -> String {
        return kHttpsUrlPrefix + shopDomain
    }

    private func getHeaders() -> [String: String]? {
        let utf8 = ("\(apiKey):\(password)").utf8
        let base64 = Data(utf8).base64EncodedString()
        return ["Authorization": "Basic \(base64)"]
    }

    private func getUrlRequest() -> URLRequestConvertible {
        let baseURLString = getBaseUrlString()
        let headers = getHeaders()
        var url = try! baseURLString.asURL()
        url = url.appendingPathComponent("/admin/countries.json")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.allHTTPHeaderFields = headers
        return try! URLEncoding.default.encode(request, with: nil)
    }
    
    private func countries(with items: [ApiJson]) -> [Country] {
        var countries: [Country] = []
        items.forEach {
            if let country = ShopifyCountryAdapter.adapt(item: $0) {
                countries.append(country)
            }
        }
        return countries
    }
    
    private func pathOfResource(withPodBundle podBundle: Bundle) -> String? {
        guard let bundleUrl = podBundle.url(forResource: "ShopApp_Shopify", withExtension: "bundle"), let bundle = Bundle(url: bundleUrl), let path = bundle.path(forResource: shopifyCountriesFileName, ofType: shopifyCountriesFileType) else {
            return nil
        }
        
        return path
    }
}

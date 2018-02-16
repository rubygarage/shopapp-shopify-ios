//
//  ShopifyAPI.swift
//  ShopClient
//
//  Created by Radyslav Krechet on 2/9/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Alamofire
import ShopClient_Gateway

private let kShopifyAdminCountriesKey = "countries"
private let kShopifyAdminCountriesRestOfWorldValue = "Rest of World"
private let kShopifyCountriesFileName = "Countries"
private let kShopifyCountriesFileType = "json"

class AdminAPI: BaseAPI {
    private let apiKey: String
    private let password: String
    private let shopDomain: String

    init(apiKey: String, password: String, shopDomain: String) {
        self.apiKey = apiKey
        self.password = password
        self.shopDomain = shopDomain
    }
    
    func getCountries(callback: @escaping RepoCallback<[Country]>) {
        let request = getUrlRequest()
        execute(request) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else if let response = response, let items = response[kShopifyAdminCountriesKey] as? [ApiJson] {
                var countries = self.countries(with: items)
                guard countries.filter({ $0.name == kShopifyAdminCountriesRestOfWorldValue }).first != nil else {
                    callback(countries, nil)
                    return
                }
                guard let path = Bundle.main.path(forResource: kShopifyCountriesFileName, ofType: kShopifyCountriesFileType) else {
                    callback(nil, ContentError())
                    return
                }
                do {
                    let url = URL(fileURLWithPath: path)
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    guard let items = json as? [ApiJson] else {
                        callback(nil, ContentError())
                        return
                    }
                    countries = self.countries(with: items)
                    callback(countries, nil)
                } catch {
                    callback(nil, ContentError())
                }
            } else {
                callback(nil, ContentError())
            }
        }
    }

    private func getBaseUrlString() -> String {
        return kHttpsUrlPrefix + shopDomain
    }

    private func getHeaders() -> [String: String]?  {
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
}

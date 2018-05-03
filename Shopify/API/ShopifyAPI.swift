//
//  ShopifyAPI.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 10/23/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import KeychainSwift
import MobileBuySDK
import ShopApp_Gateway

typealias PaymentByApplePayResponse = (order: Order?, error: RepoError?)

let kHttpsUrlPrefix = "https://"

public class ShopifyAPI: API, PaySessionDelegate {
    private let shopifyItemsMaxCount: Int32 = 250
    private let shopifyPaymetTypeApplePay = "apple_pay"
    private let shopifyRetryFinite = 10
    private let shopifyQueryAndOperator = "AND"
    private let shopifyQueryNotOperator = "NOT"
    private let shopifyQueryTitleField = "title"
    private let shopifyQueryProductTypeField = "product_type"
    private let wwwUrlPrefix = "www."
    private let shopDomain: String
    private let applePayMerchantId: String?
    
    private var adminApi: AdminAPI
    private var client: Graph.Client
    private var cardClient: Card.Client
    private var paySession: PaySession?
    private var paymentByApplePayCompletion: RepoCallback<Order>?
    private var paymentByApplePayCustomerEmail: String!
    private var paymentByApplePayResponse: PaymentByApplePayResponse?
    
    /**
     Initializer for Shopify API.
     
     - Parameter apiKey: API Key
     - Parameter shopDomain: Domain of shop
     - Parameter adminApiKey: API key for Admin API for sync available countries and states for shipping
     - Parameter adminPassword: Password for Admin API
     - Parameter applePayMerchantId: Merchant ID for Apple Pay. Optional.
     */
    public init(apiKey: String, shopDomain: String, adminApiKey: String, adminPassword: String, applePayMerchantId: String?) {
        self.shopDomain = shopDomain
        self.applePayMerchantId = applePayMerchantId

        adminApi = AdminAPI(apiKey: adminApiKey, password: adminPassword, shopDomain: shopDomain)
        client = Graph.Client(shopDomain: shopDomain, apiKey: apiKey)
        cardClient = Card.Client()
    }
    
    convenience init(apiKey: String, shopDomain: String, adminApiKey: String, adminPassword: String, applePayMerchantId: String?, client: Graph.Client, adminApi: AdminAPI, cardClient: Card.Client) {
        self.init(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId)
        self.client = client
        self.adminApi = adminApi
        self.cardClient = cardClient
    }
    
    /**
     Initializer for Shopify API which reads properties from Shopify.plist.
     
     Put file Shopify.plist into main application. File format:
     
     ```
     <dict>
     <key>apiKey</key>
     <string>PUT YOUR API KEY</string>
     <key>shopDomain</key>
     <string>PUT YOUR SHOP DOMAIN</string>
     <key>adminApiKey</key>
     <string>PUT YOUR ADMIN API KEY</string>
     <key>adminPassword</key>
     <string>PUT YOUR ADMIN PASSWORD</string>
     <key>applePayMerchantId</key>
     <string>PUT YOUR APPLE PAY MERCHANT ID IF YOU WANT USE APPLE PAY</string>
     </dict>
     ```
     */
    public convenience init?() {
        guard let fileUrl = Bundle.main.url(forResource: "Shopify", withExtension: "plist") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileUrl) else {
            return nil
        }
        
        guard let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        
        if let apiKey = config!["apiKey"] as? String,
            let shopDomain = config!["shopDomain"] as? String,
            let adminApiKey = config!["adminApiKey"] as? String,
            let adminPassword = config!["adminPassword"] as? String {
            
            let applePayMerchantId = config!["applePayMerchantId"] as? String
            
            self.init(apiKey: apiKey, shopDomain: shopDomain, adminApiKey: adminApiKey, adminPassword: adminPassword, applePayMerchantId: applePayMerchantId)
        } else {
            return nil
        }
    }


    // MARK: - Shop info

    public func getShopInfo(callback: @escaping RepoCallback<Shop>) {
        let query = Storefront.buildQuery { $0
            .shop { $0
                .name()
                .description()
                .privacyPolicy(policyQuery())
                .refundPolicy(policyQuery())
                .termsOfService(policyQuery())
                .paymentSettings(paymentSettingsQuery())
            }
        }

        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            let shopObject = ShopifyShopAdapter.adapt(item: response?.shop)
            let error = self?.process(error: error)
            callback(shopObject, error)
        })
        run(task: task, callback: callback)
    }

    // MARK: - Products

    public func getProductList(perPage: Int, paginationValue: Any?, sortBy: SortingValue?, keyPhrase: String?, excludePhrase: String?, reverse: Bool, callback: @escaping RepoCallback<[Product]>) {
        let query = productsListQuery(with: perPage, after: paginationValue, searchPhrase: nil, sortBy: sortBy, keyPhrase: keyPhrase, excludePhrase: excludePhrase, reverse: reverse)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            var products = [Product]()
            let currency = response?.shop.paymentSettings.currencyCode.rawValue
            if let edges = response?.shop.products.edges {
                for edge in edges {
                    if let product = ShopifyProductAdapter.adapt(item: edge, currencyValue: currency) {
                        products.append(product)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(products, responseError)
        })
        run(task: task, callback: callback)
    }

    public func getProduct(id: String, callback: @escaping RepoCallback<Product>) {
        let query = productDetailsQuery(id: id)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            let productNode = response?.node as? Storefront.Product
            let currency = response?.shop.paymentSettings.currencyCode.rawValue
            let productObject = ShopifyProductAdapter.adapt(item: productNode, currencyValue: currency)
            let responseError = self?.process(error: error)
            callback(productObject, responseError)
        })
        run(task: task, callback: callback)
    }

    public func searchProducts(perPage: Int, paginationValue: Any?, searchQuery: String, callback: @escaping RepoCallback<[Product]>) {
        let query = productsListQuery(with: perPage, after: paginationValue, searchPhrase: searchQuery, sortBy: .name, keyPhrase: nil, excludePhrase: nil, reverse: false)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            var products = [Product]()
            let currency = response?.shop.paymentSettings.currencyCode.rawValue
            if let edges = response?.shop.products.edges {
                for edge in edges {
                    if let product = ShopifyProductAdapter.adapt(item: edge, currencyValue: currency) {
                        products.append(product)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(products, responseError)
        })
        run(task: task, callback: callback)
    }
    
    public func getProductVariantList(ids: [String], callback: @escaping RepoCallback<[ProductVariant]>) {
        let query = productVariantListIdsQuery(ids: ids)
        let task = client.queryGraphWith(query) { [weak self] (response, error) in
            var productVariants = [ProductVariant]()
            if let nodes = response?.nodes {
                for node in nodes {
                    if let productVariant = ShopifyProductVariantAdapter.adapt(item: (node as? Storefront.ProductVariant), productId: nil, productImage: nil) {
                        productVariants.append(productVariant)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(productVariants, responseError)
        }
        run(task: task, callback: callback)
    }

    // MARK: - Categories

    public func getCategoryList(perPage: Int, paginationValue: Any?, sortBy: SortingValue?, reverse: Bool, callback: @escaping RepoCallback<[ShopApp_Gateway.Category]>) {
        let query = categoryListQuery(perPage: perPage, after: paginationValue, sortBy: sortBy, reverse: reverse)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            var categories = [ShopApp_Gateway.Category]()
            let currency = response?.shop.paymentSettings.currencyCode.rawValue
            if let categoryEdges = response?.shop.collections.edges {
                for categoryEdge in categoryEdges {
                    if let category = ShopifyCategoryAdapter.adapt(item: categoryEdge, currencyValue: currency) {
                        categories.append(category)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(categories, responseError)
        })
        run(task: task, callback: callback)
    }

    public func getCategoryDetails(id: String, perPage: Int, paginationValue: Any?, sortBy: SortingValue?, reverse: Bool, callback: @escaping RepoCallback<ShopApp_Gateway.Category>) {
        let query = categoryDetailsQuery(id: id, perPage: perPage, after: paginationValue, sortBy: sortBy, reverse: reverse)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            let categoryNode = response?.node as? Storefront.Collection
            let currency = response?.shop.paymentSettings.currencyCode.rawValue
            let category = ShopifyCategoryAdapter.adapt(item: categoryNode, currencyValue: currency)
            let responseError = self?.process(error: error)
            callback(category, responseError)
        })
        run(task: task, callback: callback)
    }

    // MARK: - Articles

    public func getArticleList(perPage: Int, paginationValue: Any?, sortBy: SortingValue?, reverse: Bool, callback: @escaping RepoCallback<[Article]>) {
        let query = articleListQuery(perPage: perPage, after: paginationValue, reverse: reverse)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            var articles = [Article]()
            if let articleEdges = response?.shop.articles.edges {
                for articleEdge in articleEdges {
                    if let article = ShopifyArticleAdapter.adapt(item: articleEdge) {
                        articles.append(article)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(articles, responseError)
        })
        run(task: task, callback: callback)
    }

    public func getArticle(id: String, callback: @escaping RepoCallback<(article: Article, baseUrl: URL)>) {
        let query = articleRootQuery(id: id)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            let responseError = self?.process(error: error)
            guard let strongSelf = self, let article = ShopifyArticleAdapter.adapt(item: response?.node as? Storefront.Article), let baseUrl = URL(string: kHttpsUrlPrefix + strongSelf.wwwUrlPrefix + strongSelf.shopDomain) else {
                callback(nil, responseError)
                return
            }
            let result = (article, baseUrl)
            callback(result, responseError)
        })
        run(task: task, callback: callback)
    }

    // MARK: - Customer

    public func signUp(with email: String, firstName: String?, lastName: String?, password: String, phone: String?, callback: @escaping RepoCallback<Bool>) {
        let query = signUpQuery(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone)
        let task = client.mutateGraphWith(query, completionHandler: { [weak self] (response, error) in
            if response?.customerCreate?.customer != nil {
                self?.getToken(with: email, password: password, callback: { (token, error) in
                    let success = token != nil
                    callback(success, RepoError(with: error))
                })
            } else if let responseError = response?.customerCreate?.userErrors.first {
                let error = self?.process(error: responseError)
                callback(false, error)
            } else {
                let responseError = self?.process(error: error)
                callback(false, responseError)
            }
        })
        run(task: task, callback: callback)
    }

    public func login(with email: String, password: String, callback: @escaping RepoCallback<Bool>) {
        getToken(with: email, password: password) { (token, error) in
            if token != nil {
                callback(true, nil)
            } else if let error = error {
                callback(false, error)
            }
        }
    }
    
    public func isLoggedIn() -> Bool {
        guard UserDefaults.standard.value(forKey: SessionData.loggedInStatus) as? Bool != nil else {
            removeSessionData()
            return false
        }
        let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
        if keyChain.get(SessionData.accessToken) != nil, let expiryDate = keyChain.get(SessionData.expiryDate), keyChain.get(SessionData.email) != nil {
            let date = Date(timeIntervalSinceNow: TimeInterval(expiryDate)!)
            return date > Date()
        }
        return false
    }

    public func logout(callback: RepoCallback<Bool>) {
        removeSessionData()
        callback(true, nil)
    }

    public func resetPassword(with email: String, callback: @escaping RepoCallback<Bool>) {
        let query = resetPasswordQuery(email: email)
        let task = client.mutateGraphWith(query) { [weak self] (_, error) in
            if let responseError = self?.process(error: error) {
                callback(false, responseError)
            } else {
                callback(true, nil)
            }
        }
        run(task: task, callback: callback)
    }

    public func getCustomer(callback: @escaping RepoCallback<Customer>) {
        if let token = sessionData().token, let email = sessionData().email {
            getCustomer(with: token, email: email, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func updateCustomer(with email: String, firstName: String?, lastName: String?, phone: String?, callback: @escaping RepoCallback<Customer>) {
        if let token = sessionData().token {
            updateCustomer(with: token, email: email, firstName: firstName, lastName: lastName, phone: phone, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func updateCustomer(with promo: Bool, callback: @escaping RepoCallback<Customer>) {
        if let token = sessionData().token {
            updateCustomer(with: token, promo: promo, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func updateCustomer(with password: String, callback: @escaping RepoCallback<Customer>) {
        if let token = sessionData().token {
            updateCustomer(with: token, password: password, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func addCustomerAddress(with address: Address, callback: @escaping RepoCallback<String>) {
        if let token = sessionData().token {
            createCustomerAddress(with: token, address: address, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func updateCustomerAddress(with address: Address, callback: @escaping RepoCallback<Bool>) {
        if let token = sessionData().token {
            updateCustomerAddress(with: token, address: address, callback: callback)
        } else {
            callback(false, ContentError())
        }
    }

    public func updateCustomerDefaultAddress(with addressId: String, callback: @escaping RepoCallback<Customer>) {
        if let token = sessionData().token {
            updateCustomerDefaultAddress(with: token, addressId: addressId, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func deleteCustomerAddress(with addressId: String, callback: @escaping RepoCallback<Bool>) {
        if let token = sessionData().token {
            deleteCustomerAddress(with: token, addressId: addressId, callback: callback)
        } else {
            callback(false, ContentError())
        }
    }

    // MARK: - Payments

    public func createCheckout(cartProducts: [CartProduct], callback: @escaping RepoCallback<Checkout>) {
        let query = checkoutCreateQuery(cartProducts: cartProducts)
        let task = client.mutateGraphWith(query, completionHandler: { [weak self] (response, error) in
            if let checkout = response?.checkoutCreate?.checkout {
                let checkoutItem = ShopifyCheckoutAdapter.adapt(item: checkout)
                callback(checkoutItem, nil)
            } else if let error = response?.checkoutCreate?.userErrors.first {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            } else {
                callback(nil, ContentError())
            }
        })
        run(task: task, callback: callback)
    }

    public func getCheckout(with checkoutId: String, callback: @escaping RepoCallback<Checkout>) {
        let query = checkoutGetQuery(with: checkoutId)
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            if let checkout = ShopifyCheckoutAdapter.adapt(item: response?.node as? Storefront.Checkout) {
                callback(checkout, nil)
            } else if let error = error {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            } else {
                callback(nil, ContentError())
            }
        })
        run(task: task, callback: callback)
    }

    public func updateShippingAddress(with checkoutId: String, address: Address, callback: @escaping RepoCallback<Bool>) {
        let shippingAddress = Storefront.MailingAddressInput.create()
        shippingAddress.update(with: address)
        let checkoutId = GraphQL.ID.init(rawValue: checkoutId)
        let query = updateShippingAddressQuery(shippingAddress: shippingAddress, checkoutId: checkoutId)
        let task = client.mutateGraphWith(query, completionHandler: { [weak self] (response, error) in
            if response?.checkoutShippingAddressUpdate?.checkout.shippingAddress != nil {
                callback(true, nil)
            } else if let error = response?.checkoutShippingAddressUpdate?.userErrors.first {
                let userError = self?.process(error: error)
                callback(false, userError)
            } else {
                callback(false, ContentError(with: error))
            }
        })
        run(task: task, callback: callback)
    }

    public func getShippingRates(with checkoutId: String, callback: @escaping RepoCallback<[ShippingRate]>) {
        let checkoutId = GraphQL.ID.init(rawValue: checkoutId)
        let query = getShippingRatesQuery(checkoutId: checkoutId)
        let task = client.queryGraphWith(query, completionHandler: { (response, error) in
            if let shippingRates = (response?.node as? Storefront.Checkout)?.availableShippingRates?.shippingRates {
                var rates = [ShippingRate]()
                for shippingRate in shippingRates {
                    if let rate = ShopifyShippingRateAdapter.adapt(item: shippingRate) {
                        rates.append(rate)
                    }
                }
                callback(rates, nil)
            }
            if let responseError = ContentError(with: error) {
                callback(nil, responseError)
            }
        })
        run(task: task, callback: callback)
    }

    public func updateCheckout(with rate: ShippingRate, checkoutId: String, callback: @escaping RepoCallback<Checkout>) {
        let id = GraphQL.ID.init(rawValue: checkoutId)
        let query = updateShippingLineQuery(checkoutId: id, shippingRateHandle: rate.handle)
        let task = client.mutateGraphWith(query, completionHandler: { (response, error) in
            if let checkout = ShopifyCheckoutAdapter.adapt(item: response?.checkoutShippingLineUpdate?.checkout) {
                callback(checkout, nil)
            } else if let responseError = ContentError(with: error) {
                callback(nil, responseError)
            } else {
                callback(nil, ContentError())
            }
        })
        run(task: task, callback: callback)
    }

    public func pay(with card: CreditCard, checkout: Checkout, billingAddress: Address, customerEmail: String, callback: @escaping RepoCallback<Order>) {
        updateCheckout(with: checkout.id, email: customerEmail, completion: { [weak self] (success, error) in
            if success == true {
                self?.createCardVault(with: card, checkout: checkout, billingAddress: billingAddress, callback: callback)
            } else if let responseError = RepoError(with: error) {
                callback(nil, responseError)
            } else {
                callback(nil, RepoError())
            }
        })
    }

    public func setupApplePay(with checkout: Checkout, customerEmail: String, callback: @escaping RepoCallback<Order>) {
        paymentByApplePayCompletion = callback
        paymentByApplePayCustomerEmail = customerEmail
        getShopCurrency { [weak self] (response, _) in
            if let currencyCode = response?.currencyCode.rawValue, let countryCode = response?.countryCode.rawValue, let shopDomain = self?.shopDomain, let applePayMerchantId = self?.applePayMerchantId {
                let payCheckout = checkout.payCheckout
                let payCurrency = PayCurrency(currencyCode: currencyCode, countryCode: countryCode)

                self?.paySession = PaySession(shopName: shopDomain, checkout: payCheckout, currency: payCurrency, merchantID: applePayMerchantId)
                self?.paySession?.delegate = self
                self?.paySession?.authorize()
            } else {
                callback(nil, ContentError())
            }
        }
    }

    public func getShopCurrency(callback: @escaping RepoCallback<Storefront.PaymentSettings>) {
        let query = Storefront.buildQuery { $0
            .shop { $0
                .paymentSettings(paymentSettingsQuery())
            }
        }

        let task = client.queryGraphWith(query, completionHandler: { (response, error) in
            callback(response?.shop.paymentSettings, RepoError(with: error))
        })
        run(task: task, callback: callback)
    }

    public func getCountries(callback: @escaping RepoCallback<[Country]>) {
        adminApi.getCountries { (countries, error) in
            if let countries = countries {
                callback(countries, nil)
            } else if let error = error {
                callback(nil, error)
            } else {
                callback(nil, ContentError())
            }
        }
    }

    // MARK: - Orders

    public func getOrderList(perPage: Int, paginationValue: Any?, callback: @escaping RepoCallback<[Order]>) {
        if let token = sessionData().token {
            getOrderList(with: token, perPage: perPage, paginationValue: paginationValue, callback: callback)
        } else {
            callback(nil, ContentError())
        }
    }

    public func getOrder(id: String, callback: @escaping RepoCallback<Order>) {
        let id = GraphQL.ID(rawValue: id)
        let query = Storefront.buildQuery { $0
            .node(id: id) { $0
                .onOrder(subfields: orderQuery())
            }
        }
        let task = client.queryGraphWith(query) { [weak self] (response, error) in
            var responseOrder: Order?
            if let node = response?.node as? Storefront.Order, let order = ShopifyOrderAdapter.adapt(item: node) {
                responseOrder = order
            }
            let responseError = self?.process(error: error)
            callback(responseOrder, responseError)
        }
        run(task: task, callback: callback)
    }

    // MARK: - Private

    private func getShippingRates(checkoutId: GraphQL.ID, callback: @escaping RepoCallback<[ShippingRate]>) {
        let query = getShippingRatesQuery(checkoutId: checkoutId)
        let task = client.queryGraphWith(query, completionHandler: { (response, error) in
            if let shippingRates = (response?.node as? Storefront.Checkout)?.availableShippingRates?.shippingRates {
                var rates = [ShippingRate]()
                for shippingRate in shippingRates {
                    if let rate = ShopifyShippingRateAdapter.adapt(item: shippingRate) {
                        rates.append(rate)
                    }
                }
                callback(rates, nil)
            }
            if let responseError = ContentError(with: error) {
                callback(nil, responseError)
            }
        })
        run(task: task, callback: callback)
    }

    private func createCardVault(with card: CreditCard, checkout: Checkout, billingAddress: Address, callback: @escaping RepoCallback<Order>) {
        let query = cardVaultUrlQuery()
        let task = client.queryGraphWith(query, completionHandler: { [weak self] (response, error) in
            if let responseError = ContentError(with: error) {
                callback(nil, responseError)
            }
            if let cardVaultUrl = response?.shop.paymentSettings.cardVaultUrl {
                self?.pay(with: card, checkout: checkout, cardVaultUrl: cardVaultUrl, address: billingAddress, callback: callback)
            }
        })
        run(task: task, callback: callback)
    }

    private func pay(with card: CreditCard, checkout: Checkout, cardVaultUrl: URL, address: Address, callback: @escaping RepoCallback<Order>) {
        let creditCard = Card.CreditCard(firstName: card.firstName, lastName: card.lastName, number: card.cardNumber, expiryMonth: card.expireMonth, expiryYear: card.expireYear, verificationCode: card.verificationCode)

        let task = cardClient.vault(creditCard, to: cardVaultUrl) { [weak self] (token, error) in
            if let token = token {
                self?.completePay(checkout: checkout, cardVaultToken: token, address: address, callback: callback)
            }
            if let responseError = ContentError(with: error) {
                callback(nil, responseError)
            }
        }
        run(task: task, callback: callback)
    }

    private func completePay(checkout: Checkout, cardVaultToken: String, address: Address, callback: @escaping RepoCallback<Order>) {
        let amount = checkout.totalPrice ?? 0
        let idempotencyKey = UUID().uuidString
        let billingAddress = Storefront.MailingAddressInput.create()
        billingAddress.update(with: address)
        let paymentInput = Storefront.CreditCardPaymentInput.create(amount: amount, idempotencyKey: idempotencyKey, billingAddress: billingAddress, vaultId: cardVaultToken)
        let checkoutId = GraphQL.ID.init(rawValue: checkout.id)

        let query = completePayQuery(checkoutId: checkoutId, paymentInput: paymentInput)
        let task = client.mutateGraphWith(query, completionHandler: { [weak self] (response, error) in
            let mutation = response?.checkoutCompleteWithCreditCard
            if mutation?.checkout != nil && mutation?.payment != nil {
                self?.completePayPolling(with: checkoutId, callback: callback)
            } else if let error = response?.checkoutCompleteWithCreditCard?.userErrors.first {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            } else {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            }
        })
        run(task: task, callback: callback)
    }

    private func completePayPolling(with checkoutId: GraphQL.ID, callback: @escaping RepoCallback<Order>) {
        let retry = Graph.RetryHandler<Storefront.QueryRoot>(endurance: .finite(shopifyRetryFinite)) { (response, _) -> Bool in
            return (response?.node as? Storefront.Checkout)?.order == nil
        }

        let query = checkoutOrderQuery(with: checkoutId)
        let task  = client.queryGraphWith(query, retryHandler: retry) { response, error in
            if let checkout = response?.node as? Storefront.Checkout, let order = ShopifyOrderAdapter.adapt(item: checkout.order) {
                callback(order, nil)
            } else {
                callback(nil, ContentError(with: error))
            }
        }
        run(task: task, callback: callback)
    }

    private func getToken(with email: String, password: String, callback: @escaping (_ token: Storefront.CustomerAccessToken?, _ error: RepoError?) -> Void) {
        let query = tokenQuery(email: email, password: password)
        let task = client.mutateGraphWith(query, completionHandler: { [weak self] (response, error) in
            if let token = response?.customerAccessTokenCreate?.customerAccessToken {
                self?.saveSessionData(with: token, email: email)
                callback(token, nil)
            } else if let error = response?.customerAccessTokenCreate?.userErrors.first {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            } else {
                let responseError = self?.process(error: error)
                callback(nil, responseError)
            }
        })
        run(task: task, callback: callback)
    }

    private func getCustomer(with token: String, email: String, callback: @escaping RepoCallback<Customer>) {
        let query = customerQuery(with: token)
        let task = client.queryGraphWith(query, completionHandler: { (response, error) in
            if let customer = ShopifyCustomerAdapter.adapt(item: response?.customer) {
                callback(customer, nil)
            } else if let responseError = error {
                callback(nil, RepoError(with: responseError))
            } else {
                callback(nil, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func updateCustomer(with token: String, email: String, firstName: String?, lastName: String?, phone: String?, callback: @escaping RepoCallback<Customer>) {
        let query = customerUpdateQuery(with: token, email: email, firstName: firstName, lastName: lastName, phone: phone)
        updateCustomer(with: query) { [weak self] (customer, error) in
            guard let strongSelf = self else {
                return
            }
            if customer != nil {
                strongSelf.updateSessionDate(with: email)
            }
            callback(customer, error)
        }
    }

    private func updateCustomer(with token: String, promo: Bool, callback: @escaping RepoCallback<Customer>) {
        let query = customerUpdateQuery(with: token, promo: promo)
        updateCustomer(with: query, callback: callback)
    }

    private func updateCustomer(with token: String, password: String, callback: @escaping RepoCallback<Customer>) {
        let query = customerUpdateQuery(with: token, password: password)
        updateCustomer(with: query) { [weak self] (customer, error) in
            guard let strongSelf = self else {
                return
            }
            if let customer = customer {
                strongSelf.login(with: customer.email, password: password, callback: { (_, error) in
                    callback(customer, error)
                })
            } else {
                callback(nil, error)
            }
        }
    }

    private func updateCustomer(with query: Storefront.MutationQuery, callback: @escaping RepoCallback<Customer>) {
        let task = client.mutateGraphWith(query, completionHandler: { (result, _) in
            if let customer = result?.customerUpdate?.customer {
                let result = ShopifyCustomerAdapter.adapt(item: customer)
                callback(result, nil)
            } else if let repoError = ShopifyRepoErrorAdapter.adapt(item: result?.customerUpdate?.userErrors.first) {
                callback(nil, NonCriticalError(with: repoError))
            } else {
                callback(nil, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func createCustomerAddress(with token: String, address: Address, callback: @escaping RepoCallback<String>) {
        let query = customerAddressCreateQuery(customerAccessToken: token, address: address)
        let task = client.mutateGraphWith(query, completionHandler: { (response, error) in
            if let addressId = response?.customerAddressCreate?.customerAddress?.id.rawValue {
                callback(addressId, nil)
            } else if let repoError = RepoError(with: error) {
                callback(nil, repoError)
            } else {
                callback(nil, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func updateCustomerDefaultAddress(with token: String, addressId: String, callback: @escaping RepoCallback<Customer>) {
        let query = customerUpdateDefaultAddressQuery(customerAccessToken: token, addressId: addressId)
        let task = client.mutateGraphWith(query, completionHandler: { (result, error) in
            if let customer = result?.customerDefaultAddressUpdate?.customer {
                callback(ShopifyCustomerAdapter.adapt(item: customer), nil)
            } else if let repoError = RepoError(with: error) {
                callback(nil, repoError)
            } else {
                callback(nil, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func updateCustomerAddress(with token: String, address: Address, callback: @escaping RepoCallback<Bool>) {
        let query = customerAddressUpdateQuery(customerAccessToken: token, address: address)
        let task = client.mutateGraphWith(query, completionHandler: { (result, error) in
            if result?.customerAddressUpdate?.customerAddress != nil {
                callback(true, nil)
            } else if let repoError = RepoError(with: error) {
                callback(false, repoError)
            } else {
                callback(false, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func deleteCustomerAddress(with token: String, addressId: String, callback: @escaping RepoCallback<Bool>) {
        let query = customerAddressDeleteQuery(addressId: addressId, token: token)
        let task = client.mutateGraphWith(query, completionHandler: { (result, error) in
            if result?.customerAddressDelete?.deletedCustomerAddressId != nil {
                callback(true, nil)
            } else if let repoError = RepoError(with: error) {
                callback(false, repoError)
            } else {
                callback(false, RepoError())
            }
        })
        run(task: task, callback: callback)
    }

    private func getOrderList(with token: String, perPage: Int, paginationValue: Any?, callback: @escaping RepoCallback<[Order]>) {
        let query = Storefront.buildQuery { $0
            .customer(customerAccessToken: token) { $0
                .orders(first: Int32(perPage), after: paginationValue as? String, reverse: true, sortKey: .processedAt) { $0
                    .edges { $0
                        .cursor()
                        .node { $0
                            .id()
                            .currencyCode()
                            .orderNumber()
                            .processedAt()
                            .totalPrice()
                            .lineItems(first: shopifyItemsMaxCount, lineItemConnectionQuery())
                        }
                    }
                }
            }
        }
        let task = client.queryGraphWith(query) { [weak self] (response, error) in
            var orders = [Order]()
            if let edges = response?.customer?.orders.edges {
                for edge in edges {
                    if let order = ShopifyOrderAdapter.adapt(item: edge) {
                        orders.append(order)
                    }
                }
            }
            let responseError = self?.process(error: error)
            callback(orders, responseError)
        }
        run(task: task, callback: callback)
    }

    // MARK: - Sorting

    private func productSortValue(for key: SortingValue?) -> Storefront.ProductSortKeys? {
        if key == nil {
            return nil
        }
        switch key! {
        case SortingValue.createdAt:
            return Storefront.ProductSortKeys.createdAt
        case SortingValue.name:
            return Storefront.ProductSortKeys.title
        case SortingValue.popular:
            return Storefront.ProductSortKeys.relevance
        case SortingValue.type:
            return Storefront.ProductSortKeys.productType
        default:
            return nil
        }
    }

    private func productCollectionSortValue(for key: SortingValue?) -> Storefront.ProductCollectionSortKeys? {
        if key == nil {
            return nil
        }
        switch key! {
        case SortingValue.createdAt:
            return Storefront.ProductCollectionSortKeys.created
        case SortingValue.priceHighToLow, SortingValue.priceLowToHigh:
            return Storefront.ProductCollectionSortKeys.price
        case SortingValue.name:
            return Storefront.ProductCollectionSortKeys.title
        default:
            return nil
        }
    }

    // MARK: - Queries building

    private func productsListQuery(with perPage: Int, after: Any?, searchPhrase: String?, sortBy: SortingValue?, keyPhrase: String?, excludePhrase: String?, reverse: Bool) -> Storefront.QueryRootQuery {
        let sortKey = productSortValue(for: sortBy)
        var query = searchPhrase
        if let keyPhrase = keyPhrase, let excludePhrase = excludePhrase, let sortKey = sortKey, sortKey == Storefront.ProductSortKeys.productType {
            query = "\(shopifyQueryNotOperator) \(shopifyQueryTitleField):\"\(excludePhrase)\" \(shopifyQueryAndOperator) \(shopifyQueryProductTypeField):\"\(keyPhrase)\""
        }

        return Storefront.buildQuery { $0
            .shop { $0
                .name()
                .paymentSettings(paymentSettingsQuery())
                .products(first: Int32(perPage), after: after as? String, reverse: reverse, sortKey: sortKey, query: query, self.productConnectionQuery())
            }
        }
    }

    private func productDetailsQuery(id: String) -> Storefront.QueryRootQuery {
        let nodeId = GraphQL.ID(rawValue: id)
        return Storefront.buildQuery({ $0
            .shop({ $0
                .paymentSettings(paymentSettingsQuery())
            })
            .node(id: nodeId, { $0
                .onProduct(subfields: productQuery(additionalInfoNedded: true))
            })
        })
    }
    
    private func productVariantListIdsQuery(ids: [String]) -> Storefront.QueryRootQuery {
        let nodeIds = ids.map({ GraphQL.ID(rawValue: $0) })
        return Storefront.buildQuery({ $0
            .nodes(ids: nodeIds, { $0
                .onProductVariant(subfields: productVariantQuery())
            })
        })
    }

    private func categoryListQuery(perPage: Int, after: Any?, sortBy: SortingValue?, reverse: Bool) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery({ $0
            .shop({ $0
                .paymentSettings(paymentSettingsQuery())
                .collections(first: Int32(perPage), after: after as? String, reverse: reverse, collectionConnectionQuery())
            })
        })
    }

    private func categoryDetailsQuery(id: String, perPage: Int, after: Any?, sortBy: SortingValue?, reverse: Bool) -> Storefront.QueryRootQuery {
        let nodeId = GraphQL.ID(rawValue: id)
        return Storefront.buildQuery { $0
            .shop({ $0
                .paymentSettings(paymentSettingsQuery())
            })
            .node(id: nodeId, { $0
                .onCollection(subfields: collectionQuery(perPage: perPage, after: after, sortBy: sortBy, reverse: reverse, productsNeeded: true))
            })
        }
    }

    private func articleListQuery(perPage: Int, after: Any?, reverse: Bool) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery({ $0
            .shop({ $0
                .articles(first: Int32(perPage), after: after as? String, reverse: reverse, articleConnectionQuery())
            })
        })
    }

    private func articleRootQuery(id: String) -> Storefront.QueryRootQuery {
        let nodeId = GraphQL.ID(rawValue: id)
        return Storefront.buildQuery({ $0
            .node(id: nodeId, { $0
                .onArticle(subfields: articleQuery())
            })
        })
    }

    private func signUpQuery(email: String, password: String, firstName: String?, lastName: String?, phone: String?) -> Storefront.MutationQuery {
        let input = Storefront.CustomerCreateInput.create(email: email, password: password)
        input.firstName = Input<String>(orNull: firstName)
        input.lastName = Input<String>(orNull: lastName)
        input.phone = Input<String>(orNull: phone)
        return Storefront.buildMutation({ $0
            .customerCreate(input: input, { $0
                .customer(customerQuery())
                .userErrors(userErrorQuery())
            })
        })
    }

    private func tokenQuery(email: String, password: String) -> Storefront.MutationQuery {
        let input = Storefront.CustomerAccessTokenCreateInput.create(email: email, password: password)
        return Storefront.buildMutation({ $0
            .customerAccessTokenCreate(input: input, { $0
                .customerAccessToken(accessTokenQuery())
                .userErrors(userErrorQuery())
            })
        })
    }

    private func resetPasswordQuery(email: String) -> Storefront.MutationQuery {
        return Storefront.buildMutation({ $0
            .customerRecover(email: email, { $0
                .userErrors(userErrorQuery())
            })

        })
    }

    private func customerQuery(with accessToken: String) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery({ $0
            .customer(customerAccessToken: accessToken, customerQuery())
        })
    }

    private func customerUpdateQuery(with accessToken: String, email: String, firstName: String?, lastName: String?, phone: String?) -> Storefront.MutationQuery {
        let input = Storefront.CustomerUpdateInput.create()
        input.firstName = firstName.orNull
        input.lastName = lastName.orNull
        input.email = Input<String>(orNull: email)
        input.phone = phone.orNull
        return Storefront.buildMutation({ $0
            .customerUpdate(customerAccessToken: accessToken, customer: input, self.customerUpdatePayloadQuery())
        })
    }

    private func customerUpdateQuery(with accessToken: String, promo: Bool) -> Storefront.MutationQuery {
        let input = Storefront.CustomerUpdateInput.create()
        input.acceptsMarketing = Input<Bool>(orNull: promo)
        return Storefront.buildMutation({ $0
            .customerUpdate(customerAccessToken: accessToken, customer: input, self.customerUpdatePayloadQuery())
        })
    }

    private func customerUpdateQuery(with accessToken: String, password: String) -> Storefront.MutationQuery {
        let input = Storefront.CustomerUpdateInput.create()
        input.password = Input<String>(orNull: password)
        return Storefront.buildMutation({ $0
            .customerUpdate(customerAccessToken: accessToken, customer: input, self.customerUpdatePayloadQuery())
        })
    }

    private func checkoutCreateQuery(cartProducts: [CartProduct]) -> Storefront.MutationQuery {
        return Storefront.buildMutation({ $0
            .checkoutCreate(input: checkoutInput(cartProducts: cartProducts), checkoutCreatePayloadQuery())
        })
    }

    private func checkoutGetQuery(with checkoutId: String) -> Storefront.QueryRootQuery {
        let id = GraphQL.ID.init(rawValue: checkoutId)
        return Storefront.buildQuery({ $0
            .node(id: id, { $0
                .onCheckout(subfields: checkoutQuery())
            })
        })
    }

    private func checkoutInput(cartProducts: [CartProduct]) -> Storefront.CheckoutCreateInput {
        let checkout = Storefront.CheckoutCreateInput.create()
        checkout.lineItems = Input<[Storefront.CheckoutLineItemInput]>(orNull: checkoutLineItemInput(cartProducts: cartProducts))
        return checkout
    }

    private func checkoutLineItemInput(cartProducts: [CartProduct]) -> [Storefront.CheckoutLineItemInput] {
        var inputs = [Storefront.CheckoutLineItemInput]()
        for product in cartProducts {
            let productId = GraphQL.ID.init(rawValue: product.productVariant?.id ?? "")
            inputs.append(Storefront.CheckoutLineItemInput.create(quantity: Int32(product.quantity), variantId: productId))
        }
        return inputs
    }

    private func cardVaultUrlQuery() -> Storefront.QueryRootQuery {
        return Storefront.buildQuery({ $0
            .shop { $0
                .paymentSettings({ $0
                    .cardVaultUrl()
                })
            }
        })
    }

    private func updateShippingAddressQuery(shippingAddress: Storefront.MailingAddressInput, checkoutId: GraphQL.ID) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .checkoutShippingAddressUpdate(shippingAddress: shippingAddress, checkoutId: checkoutId, { $0
                .checkout({ $0
                    .ready()
                    .shippingLine({ $0
                        .price()
                    })
                    .shippingAddress(mailingAddressQuery())
                })
                .userErrors(userErrorQuery())
            })
        }
    }

    private func customerUpdateDefaultAddressQuery(customerAccessToken: String, addressId: String) -> Storefront.MutationQuery {
        let id = GraphQL.ID.init(rawValue: addressId)
        return Storefront.buildMutation({ $0
            .customerDefaultAddressUpdate(customerAccessToken: customerAccessToken, addressId: id, customerDefaultAddressUpdatePayloadQuery())
        })
    }

    private func customerAddressCreateQuery(customerAccessToken: String, address: Address) -> Storefront.MutationQuery {
        let addressInput = Storefront.MailingAddressInput.create()
        addressInput.update(with: address)
        return Storefront.buildMutation({ $0
            .customerAddressCreate(customerAccessToken: customerAccessToken, address: addressInput, customerAddressCreatePayloadQuery())
        })
    }

    private func customerAddressUpdateQuery(customerAccessToken: String, address: Address) -> Storefront.MutationQuery {
        let addressId = GraphQL.ID.init(rawValue: address.id)
        let addressInput = Storefront.MailingAddressInput.create()
        addressInput.update(with: address)
        return Storefront.buildMutation({ $0
            .customerAddressUpdate(customerAccessToken: customerAccessToken, id: addressId, address: addressInput, customerAddressUpdatePayloadQuery())
        })
    }

    private func customerAddressDeleteQuery(addressId: String, token: String) -> Storefront.MutationQuery {
        let id = GraphQL.ID.init(rawValue: addressId)
        return Storefront.buildMutation({ $0
            .customerAddressDelete(id: id, customerAccessToken: token, customerAddressDeletePayloadQuery())
        })
    }

    private func getShippingRatesQuery(checkoutId: GraphQL.ID) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery { $0
            .node(id: checkoutId) { $0
                .onCheckout { $0
                    .id()
                    .availableShippingRates { $0
                        .ready()
                        .shippingRates(shippingRateQuery())
                    }
                }
            }
        }
    }

    private func updateShippingLineQuery(checkoutId: GraphQL.ID, shippingRateHandle: String) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .checkoutShippingLineUpdate(checkoutId: checkoutId, shippingRateHandle: shippingRateHandle, { $0
                .checkout(checkoutQuery())
                .userErrors(userErrorQuery())
            })
        }
    }

    private func completePayQuery(checkoutId: GraphQL.ID, paymentInput: Storefront.CreditCardPaymentInput) -> Storefront.MutationQuery {
        return Storefront.buildMutation { $0
            .checkoutCompleteWithCreditCard(checkoutId: checkoutId, payment: paymentInput, { $0
                .payment({ $0
                    .ready()
                    .errorMessage()
                })
                .checkout({ $0
                    .ready()
                })
                .userErrors(userErrorQuery())
            })
        }
    }

    private func paymentNodeQuery(with paymentId: GraphQL.ID) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery { $0
            .node(id: paymentId) { $0
                .onPayment(subfields: paymentQuery())
            }
        }
    }

    private func checkoutOrderQuery(with checkoutId: GraphQL.ID) -> Storefront.QueryRootQuery {
        return Storefront.buildQuery({ $0
            .node(id: checkoutId, { $0
                .onCheckout(subfields: { $0
                    .order(orderQuery())
                })
            })
        })
    }

    // MARK: - Subqueries

    private func productConnectionQuery() -> (Storefront.ProductConnectionQuery) -> Void {
        return { (query: Storefront.ProductConnectionQuery) in
            query.edges({ $0
                .cursor()
                .node(self.productQuery(variantsPriceNeeded: true))
            })
        }
    }

    private func productQuery(additionalInfoNedded: Bool = false, variantsPriceNeeded: Bool = false) -> (Storefront.ProductQuery) -> Void {
        let imageCount = additionalInfoNedded ? shopifyItemsMaxCount : 1
        let variantsCount = additionalInfoNedded || variantsPriceNeeded ? shopifyItemsMaxCount : 1

        return { (query: Storefront.ProductQuery) in
            query.id()
            query.title()
            query.description()
            query.descriptionHtml()
            query.vendor()
            query.productType()
            query.createdAt()
            query.updatedAt()
            query.tags()
            query.images(first: imageCount, self.imageConnectionQuery())
            query.variants(first: variantsCount, variantsPriceNeeded ? self.shortVariantConnectionQuery() : self.variantConnectionQuery())
            query.options(self.optionQuery())
        }
    }

    private func shortProductQuery() -> (Storefront.ProductQuery) -> Void {
        return { (query: Storefront.ProductQuery) in
            query.id()
            query.images(first: 1, self.imageConnectionQuery())
            query.options(self.optionQuery())
        }
    }

    private func imageConnectionQuery() -> (Storefront.ImageConnectionQuery) -> Void {
        return { (query: Storefront.ImageConnectionQuery) in
            query.edges({ $0
                .node(self.imageQuery())
            })
        }
    }

    private func imageQuery() -> (Storefront.ImageQuery) -> Void {
        return { (query: Storefront.ImageQuery) in
            query.id()
            query.src()
            query.altText()
        }
    }

    private func variantConnectionQuery() -> (Storefront.ProductVariantConnectionQuery) -> Void {
        return { (query: Storefront.ProductVariantConnectionQuery) in
            query.edges({ $0
                .node(self.productVariantQuery())
            })
        }
    }

    private func shortVariantConnectionQuery() -> (Storefront.ProductVariantConnectionQuery) -> Void {
        return { (query: Storefront.ProductVariantConnectionQuery) in
            query.edges({ $0
                .node(self.shortProductVariantQuery())
            })
        }
    }

    private func productVariantQuery() -> (Storefront.ProductVariantQuery) -> Void {
        return { (query: Storefront.ProductVariantQuery) in
            query.id()
            query.title()
            query.price()
            query.availableForSale()
            query.image(self.imageQuery())
            query.selectedOptions(self.selectedOptionQuery())
        }
    }

    private func productVariantWithShortProductQuery() -> (Storefront.ProductVariantQuery) -> Void {
        return { (query: Storefront.ProductVariantQuery) in
            query.id()
            query.title()
            query.price()
            query.availableForSale()
            query.image(self.imageQuery())
            query.selectedOptions(self.selectedOptionQuery())
            query.product(self.shortProductQuery())
        }
    }

    private func shortProductVariantQuery() -> (Storefront.ProductVariantQuery) -> Void {
        return { (query: Storefront.ProductVariantQuery) in
            query.price()
        }
    }

    private func collectionConnectionQuery() -> (Storefront.CollectionConnectionQuery) -> Void {
        return { (query: Storefront.CollectionConnectionQuery) in
            query.edges({ $0
                .cursor()
                .node(self.collectionQuery(sortBy: nil, reverse: false))
            })

        }
    }

    private func collectionQuery(perPage: Int = 0, after: Any? = nil, sortBy: SortingValue?, reverse: Bool, productsNeeded: Bool = false) -> (Storefront.CollectionQuery) -> Void {
        let sortKey = productCollectionSortValue(for: sortBy)
        return { (query: Storefront.CollectionQuery) in
            query.id()
            query.title()
            query.description()
            query.updatedAt()
            query.image(self.imageQuery())
            if productsNeeded {
                query.products(first: Int32(perPage), after: after as? String, reverse: reverse, sortKey: sortKey, self.productConnectionQuery())
            }
            if perPage > 0 {
                query.descriptionHtml()
            }
        }
    }

    private func policyQuery() -> (Storefront.ShopPolicyQuery) -> Void {
        return { (query: Storefront.ShopPolicyQuery) in
            query.title()
            query.body()
            query.url()
        }
    }

    private func articleConnectionQuery() -> (Storefront.ArticleConnectionQuery) -> Void {
        return { (query: Storefront.ArticleConnectionQuery) in
            query.edges({ $0
                .node(self.articleQuery())
                .cursor()
            })
        }
    }

    private func articleQuery() -> (Storefront.ArticleQuery) -> Void {
        return { (query: Storefront.ArticleQuery) in
            query.id()
            query.title()
            query.content()
            query.contentHtml()
            query.image(self.imageQuery())
            query.author(self.authorQuery())
            query.tags()
            query.blog(self.blogQuery())
            query.publishedAt()
            query.url()
        }
    }

    private func authorQuery() -> (Storefront.ArticleAuthorQuery) -> Void {
        return { (query: Storefront.ArticleAuthorQuery) in
            query.firstName()
            query.lastName()
            query.name()
            query.email()
            query.bio()
        }
    }

    private func blogQuery() -> (Storefront.BlogQuery) -> Void {
        return { (query: Storefront.BlogQuery) in
            query.id()
            query.title()
        }
    }

    private func optionQuery() -> (Storefront.ProductOptionQuery) -> Void {
        return { (query: Storefront.ProductOptionQuery) in
            query.id()
            query.name()
            query.values()
        }
    }

    private func paymentSettingsQuery() -> (Storefront.PaymentSettingsQuery) -> Void {
        return { (query: Storefront.PaymentSettingsQuery) in
            query.currencyCode()
            query.countryCode()
        }
    }

    private func selectedOptionQuery() -> (Storefront.SelectedOptionQuery) -> Void {
        return { (query: Storefront.SelectedOptionQuery) in
            query.name()
            query.value()
        }
    }

    private func customerQuery() -> (Storefront.CustomerQuery) -> Void {
        return { (query: Storefront.CustomerQuery) in
            query.email()
            query.firstName()
            query.lastName()
            query.phone()
            query.acceptsMarketing()
            query.defaultAddress(self.mailingAddressQuery())
            query.addresses(first: self.shopifyItemsMaxCount, self.mailingAddressConnectionQuery())
        }
    }

    private func customerUpdatePayloadQuery() -> (Storefront.CustomerUpdatePayloadQuery) -> Void {
        return { (query: Storefront.CustomerUpdatePayloadQuery) in
            query.customer(self.customerQuery())
            query.userErrors(self.userErrorQuery())
        }
    }

    private func userErrorQuery() -> (Storefront.UserErrorQuery) -> Void {
        return { (query: Storefront.UserErrorQuery) in
            query.message()
            query.field()
        }
    }

    private func accessTokenQuery() -> (Storefront.CustomerAccessTokenQuery) -> Void {
        return { (query) in
            query.accessToken()
            query.expiresAt()
        }
    }

    private func checkoutCreatePayloadQuery() -> (Storefront.CheckoutCreatePayloadQuery) -> Void {
        return { (query) in
            query.checkout(self.checkoutQuery())
            query.userErrors(self.userErrorQuery())
        }
    }

    private func checkoutQuery() -> (Storefront.CheckoutQuery) -> Void {
        return { (query) in
            query.id()
            query.webUrl()
            query.currencyCode()
            query.subtotalPrice()
            query.totalPrice()
            query.availableShippingRates(self.availableShippingRatesQuery())
            query.shippingLine(self.shippingRateQuery())
            query.shippingAddress(self.mailingAddressQuery())
            query.lineItems(first: self.shopifyItemsMaxCount, self.checkoutLineItemConnectionQuery())
        }
    }

    func availableShippingRatesQuery() -> (Storefront.AvailableShippingRatesQuery) -> Void {
        return { (query: Storefront.AvailableShippingRatesQuery) in
            query.shippingRates(self.shippingRateQuery())
        }
    }

    private func checkoutLineItemConnectionQuery() -> (Storefront.CheckoutLineItemConnectionQuery) -> Void {
        return { (query: Storefront.CheckoutLineItemConnectionQuery) in
            query.edges(self.checkoutLineItemEdgeQuery())
        }
    }

    private func checkoutLineItemEdgeQuery() -> (Storefront.CheckoutLineItemEdgeQuery) -> Void {
        return { (query: Storefront.CheckoutLineItemEdgeQuery) in
            query.node(self.checkoutLineItemQuery())
        }
    }

    private func checkoutLineItemQuery() -> (Storefront.CheckoutLineItemQuery) -> Void {
        return { (query: Storefront.CheckoutLineItemQuery) in
            query.id()
            query.quantity()
            query.variant(self.productVariantQuery())
        }
    }

    private func mailingAddressConnectionQuery() -> (Storefront.MailingAddressConnectionQuery) -> Void {
        return { (query) in
            query.edges(self.mailingAddressEdgeQuery())
        }
    }

    private func mailingAddressEdgeQuery() -> (Storefront.MailingAddressEdgeQuery) -> Void {
        return { (query) in
            query.node(self.mailingAddressQuery())
        }
    }

    private func mailingAddressQuery() -> (Storefront.MailingAddressQuery) -> Void {
        return { (query) in
            query.id()
            query.country()
            query.firstName()
            query.lastName()
            query.address1()
            query.address2()
            query.city()
            query.province()
            query.zip()
            query.phone()
        }
    }

    private func customerDefaultAddressUpdatePayloadQuery() -> (Storefront.CustomerDefaultAddressUpdatePayloadQuery) -> Void {
        return { (query: Storefront.CustomerDefaultAddressUpdatePayloadQuery) in
            query.customer(self.customerQuery())
        }
    }

    private func customerAddressCreatePayloadQuery() -> (Storefront.CustomerAddressCreatePayloadQuery) -> Void {
        return { (query) in
            query.customerAddress(self.mailingAddressQuery())
            query.userErrors(self.userErrorQuery())
        }
    }

    private func customerAddressUpdatePayloadQuery() -> (Storefront.CustomerAddressUpdatePayloadQuery) -> Void {
        return { (query) in
            query.customerAddress(self.mailingAddressQuery())
            query.userErrors(self.userErrorQuery())
        }
    }

    private func customerAddressDeletePayloadQuery() -> (Storefront.CustomerAddressDeletePayloadQuery) -> Void {
        return { (query) in
            query.deletedCustomerAddressId()
            query.userErrors(self.userErrorQuery())
        }
    }

    private func lineItemConnectionQuery() -> (Storefront.OrderLineItemConnectionQuery) -> Void {
        return { (query: Storefront.OrderLineItemConnectionQuery) in
            query.edges({ $0
                .node { $0
                    .quantity()
                    .title()
                    .variant(self.productVariantWithShortProductQuery())
                }
            })
        }
    }

    private func shippingRateQuery() -> (Storefront.ShippingRateQuery) -> Void {
        return { (query: Storefront.ShippingRateQuery) in
            query.title()
            query.price()
            query.handle()
        }
    }

    private func paymentQuery() -> (Storefront.PaymentQuery) -> Void {
        return { (query: Storefront.PaymentQuery) in
            query.id()
            query.ready()
        }
    }

    private func orderQuery() -> (Storefront.OrderQuery) -> Void {
        return { (query: Storefront.OrderQuery) in
            query.id()
            query.orderNumber()
            query.currencyCode()
            query.totalPrice()
            query.subtotalPrice()
            query.totalShippingPrice()
            query.processedAt()
            query.shippingAddress(self.mailingAddressQuery())
            query.lineItems(first: self.shopifyItemsMaxCount, self.lineItemConnectionQuery())
        }
    }

    // MARK: - Session data

    private func saveSessionData(with token: Storefront.CustomerAccessToken, email: String) {
        let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
        keyChain.set(token.accessToken, forKey: SessionData.accessToken)
        keyChain.set(email, forKey: SessionData.email)
        let expiryString = String(describing: token.expiresAt.timeIntervalSinceNow)
        keyChain.set(expiryString, forKey: SessionData.expiryDate)
        UserDefaults.standard.set(true, forKey: SessionData.loggedInStatus)
    }

    private func updateSessionDate(with email: String) {
        let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
        keyChain.set(email, forKey: SessionData.email)
    }

    private func sessionData() -> (token: String?, email: String?, expiryDate: Date?) {
        let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
        let token = keyChain.get(SessionData.accessToken)
        let email = keyChain.get(SessionData.email)
        let expiryDateString = keyChain.get(SessionData.expiryDate) ?? ""
        let expiryDateTimeInterval = TimeInterval(expiryDateString) ?? TimeInterval()
        let expiryDate = Date(timeIntervalSinceNow: expiryDateTimeInterval)

        return (token, email, expiryDate)
    }

    private func removeSessionData() {
        let keyChain = KeychainSwift(keyPrefix: SessionData.keyPrefix)
        keyChain.clear()
        UserDefaults.standard.set(false, forKey: SessionData.loggedInStatus)
    }

    // MARK: - Check connection network

    private func run<T>(task: Task?, callback: RepoCallback<T>) {
        if ReachabilityNetwork.hasConnection() {
            task?.resume()
        } else {
            callback(nil, NetworkError())
        }
    }

    // MARK: - Error handling

    private func process(error: Graph.QueryError?) -> RepoError? {
        if let error = error, case .request(let requestError) = error {
            return ContentError(with: requestError)
        }

        if let error = error, case .invalidQuery(let reasons) = error {
            return CriticalError(with: error, message: reasons.first?.message)
        }

        if let error = error, case .http(let statusCode) = error {
            return process(statusCode: statusCode, error: error)
        }

        return RepoError(with: error)
    }

    private func process(error: Storefront.UserError?) -> RepoError? {
        let repoError = ShopifyRepoErrorAdapter.adapt(item: error)
        return NonCriticalError(with: repoError)
    }

    private func process(statusCode: Int, error: Error) -> RepoError? {
        return CriticalError(with: error, statusCode: statusCode)
    }

    // MARK: - PaySessionDelegate

    public func paySession(_ paySession: PaySession, didRequestShippingRatesFor address: PayPostalAddress, checkout: PayCheckout, provide: @escaping (PayCheckout?, [PayShippingRate]) -> Void) {
        updateCheckout(with: checkout.id, updatingPartialShippingAddress: address) { [weak self] (response, error) in
            if let checkout = ShopifyCheckoutAdapter.adapt(item: response)?.payCheckout {
                self?.fetchShippingRatesForCheckout(with: checkout.id, completion: { (ratesResponse, error) in
                    if error != nil {
                        provide(nil, [])
                    } else {
                        let rates = ratesResponse.map({ ShopifyShippingRateAdapter.adapt(item: $0)!.payShippingRate })
                        provide(checkout, rates)
                    }
                })
            } else {
                provide(nil, [])
            }
        }
    }

    public func paySession(_ paySession: PaySession, didUpdateShippingAddress address: PayPostalAddress, checkout: PayCheckout, provide: @escaping (PayCheckout?) -> Void) {
        // This method is called *only* for checkouts that don't require shipping.
        provide(checkout)
    }

    public func paySession(_ paySession: PaySession, didSelectShippingRate shippingRate: PayShippingRate, checkout: PayCheckout, provide: @escaping (PayCheckout?) -> Void) {
        let selectedRate = ShippingRate()
        selectedRate.handle = shippingRate.handle
        selectedRate.price = shippingRate.price.description
        selectedRate.title = shippingRate.title
        updateCheckout(with: selectedRate, checkoutId: checkout.id) { (response, _) in
            if let payCheckout = response?.payCheckout {
                provide(payCheckout)
            } else {
                provide(nil)
            }
        }
    }

    public func paySession(_ paySession: PaySession, didAuthorizePayment authorization: PayAuthorization, checkout: PayCheckout, completeTransaction: @escaping (PaySession.TransactionStatus) -> Void) {
        let idempotencyKey = UUID().uuidString
        updateCheckout(with: checkout.id, email: paymentByApplePayCustomerEmail, completion: { [weak self] (success, error) in
            self?.completeCheckout(checkout, billingAddress: authorization.billingAddress, applePayToken: authorization.token, idempotencyToken: idempotencyKey, completion: { [weak self] (order, error) in
                guard let strongSelf = self else {
                    return
                }
                if let order = order {
                    strongSelf.paymentByApplePayResponse = (order, nil)
                    completeTransaction(.success)
                } else {
                    strongSelf.paymentByApplePayResponse = (nil, error)
                    completeTransaction(.failure)
                }
            })
        })
    }

    public func paySessionDidFinish(_ paySession: PaySession) {
        paymentByApplePayCompletion?(paymentByApplePayResponse?.order, paymentByApplePayResponse?.error)
        paymentByApplePayResponse = nil
        paymentByApplePayCompletion = nil
    }

    // MARK: - Pay session delegate additional methods

    private func updateCheckout(with checkoutId: String, updatingPartialShippingAddress address: PayPostalAddress, completion: @escaping (_ checkout: Storefront.Checkout?, _ error: Graph.QueryError?) -> Void) {
        let mutation = mutationForUpdateCheckout(with: checkoutId, updatingPartialShippingAddress: address)
        let task = client.mutateGraphWith(mutation, completionHandler: { (response, error) in
            completion(response?.checkoutShippingAddressUpdate?.checkout, error)
        })
        task.resume()
    }

    private func fetchShippingRatesForCheckout(with id: String, completion: @escaping (_ rates: [Storefront.ShippingRate], _ error: Graph.QueryError?) -> Void) {
        let retry = Graph.RetryHandler<Storefront.QueryRoot>(endurance: .finite(shopifyRetryFinite)) { (response, _) -> Bool in
            if let response = response {
                return (response.node as! Storefront.Checkout).availableShippingRates?.ready ?? false == false
            } else {
                return false
            }
        }

        let checkoutID = GraphQL.ID(rawValue: id)
        let query = getShippingRatesQuery(checkoutId: checkoutID)
        let task = client.queryGraphWith(query, retryHandler: retry, completionHandler: { (response, error) in
            let checkout = response?.node as? Storefront.Checkout
            let rates = checkout?.availableShippingRates?.shippingRates ?? [Storefront.ShippingRate]()
            completion(rates, error)
        })
        task.resume()
    }

    public func updateCheckout(with checkoutId: String, email: String, completion: @escaping (_ success: Bool, _ error: Graph.QueryError?) -> Void) {
        let mutation = mutationForUpdateCheckout(with: checkoutId, updatingEmail: email)
        let task = client.mutateGraphWith(mutation, completionHandler: { (response, error) in
            let success = response != nil
            completion(success, error)
        })
        task.resume()
    }

    public func completeCheckout(_ checkout: PayCheckout, billingAddress: PayAddress, applePayToken token: String, idempotencyToken: String, completion: @escaping (_ order: Order?, _ error: RepoError?) -> Void) {
        let mutation = mutationForCompleteCheckoutUsingApplePay(with: checkout, billingAddress: billingAddress, token: token, idempotencyToken: idempotencyToken)
        let task = client.mutateGraphWith(mutation, completionHandler: { [weak self] (response, error) in
            if response?.checkoutCompleteWithTokenizedPayment?.payment != nil {
                let checkoutId = GraphQL.ID.init(rawValue: checkout.id)
                self?.completePayPolling(with: checkoutId, callback: completion)
            } else if let responseError = response?.checkoutCompleteWithTokenizedPayment?.userErrors.first {
                let error = self?.process(error: responseError)
                completion(nil, error)
            } else {
                completion(nil, RepoError())
            }
        })
        task.resume()
    }

    // MARK: - Pay session delegate additional submethods

    private func mutationForUpdateCheckout(with id: String, updatingPartialShippingAddress address: PayPostalAddress) -> Storefront.MutationQuery {
        let checkoutID = GraphQL.ID(rawValue: id)
        let addressInput = Storefront.MailingAddressInput.create(city: address.city.orNull, country: address.country.orNull, province: address.province.orNull, zip: address.zip.orNull)

        return Storefront.buildMutation { $0
            .checkoutShippingAddressUpdate(shippingAddress: addressInput, checkoutId: checkoutID) { $0
                .userErrors(self.userErrorQuery())
                .checkout(self.checkoutQuery())
            }
        }
    }

    private func mutationForCompleteCheckoutUsingApplePay(with checkout: PayCheckout, billingAddress: PayAddress, token: String, idempotencyToken: String) -> Storefront.MutationQuery {
        let checkoutID = GraphQL.ID(rawValue: checkout.id)

        let mailingAddress = Storefront.MailingAddressInput.create(
            address1: billingAddress.addressLine1.orNull,
            address2: billingAddress.addressLine2.orNull,
            city: billingAddress.city.orNull,
            country: billingAddress.country.orNull,
            firstName: billingAddress.firstName.orNull,
            lastName: billingAddress.lastName.orNull,
            province: billingAddress.province.orNull,
            zip: billingAddress.zip.orNull
        )

        let paymentInput = Storefront.TokenizedPaymentInput.create(
            amount: checkout.paymentDue,
            idempotencyKey: idempotencyToken,
            billingAddress: mailingAddress,
            type: shopifyPaymetTypeApplePay,
            paymentData: token
        )

        return Storefront.buildMutation({ $0
            .checkoutCompleteWithTokenizedPayment(checkoutId: checkoutID, payment: paymentInput, { $0
                .payment(self.paymentQuery())
                .userErrors(self.userErrorQuery())
            })
        })
    }

    private func mutationForUpdateCheckout(with id: String, updatingEmail email: String) -> Storefront.MutationQuery {
        let checkoutId = GraphQL.ID(rawValue: id)
        return Storefront.buildMutation { $0
            .checkoutEmailUpdate(checkoutId: checkoutId, email: email) { $0
                .userErrors(self.userErrorQuery())
                .checkout({ $0
                    .id()
                })
            }
        }
    }
}

extension Storefront.MailingAddressInput {
    func update(with address: Address) {
        address1 = address.address.orNull
        address2 = address.secondAddress.orNull
        city = address.city.orNull
        country = address.country.orNull
        firstName = address.firstName.orNull
        lastName = address.lastName.orNull
        zip = address.zip.orNull
        phone = address.phone.orNull
        if let state = address.state, state.isEmpty == false {
            province = address.state.orNull
        }
    }
}

extension Checkout {
    var payCheckout: PayCheckout {
        let payItems = lineItems.map { item in
            PayLineItem(price: item.price!, quantity: item.quantity)
        }
        let payAddress = PayAddress(addressLine1: shippingAddress?.address, addressLine2: shippingAddress?.secondAddress, city: shippingAddress?.city, country: shippingAddress?.country, province: shippingAddress?.state, zip: shippingAddress?.zip, firstName: shippingAddress?.firstName, lastName: shippingAddress?.lastName, phone: shippingAddress?.phone, email: nil)

        return PayCheckout(
            id: id,
            lineItems: payItems,
            discount: nil,
            shippingAddress: payAddress,
            shippingRate: shippingLine?.payShippingRate,
            subtotalPrice: subtotalPrice!,
            needsShipping: true,
            totalTax: Decimal(0),
            paymentDue: totalPrice!
        )
    }
}

extension ShippingRate {
    var payShippingRate: PayShippingRate {
        return PayShippingRate(
            handle: handle,
            title: title!,
            price: Decimal(string: price!)!
        )
    }
}

Pod::Spec.new do |s|
  s.name         = "ShopApp_Shopify"
  s.version      = "1.0.4"
  s.summary      = "ShopApp_Shopify description"
  s.homepage     = "https://github.com/rubygarage/shopapp-shopify-ios"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE.txt" }
  s.author       = { "Mykola Voronin" => "nvoronin@rubygarage.org" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/rubygarage/shopapp-shopify-ios.git", :tag => "#{s.version}" }
  s.source_files  = "Shopify/**/*.swift"
  s.resource_bundles = {
    "ShopApp_Shopify" => ["Shopify/Countries.json"]
  }
  s.dependency "Mobile-Buy-SDK", "~> 3.1"
  s.dependency "KeychainSwift", "~> 10.0"
  s.dependency "Alamofire", "~> 4.5"
  s.dependency "CoreStore", "~> 4.2"
  s.dependency "ShopApp_Gateway"
end

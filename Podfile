# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Shopify' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Shopify
  pod "Mobile-Buy-SDK", "3.1.5"
  pod "KeychainSwift", "~> 14.0"
  pod "Alamofire", "~> 4.8"
  pod 'ShopApp_Gateway', "~> 1.0"

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['Mobile-Buy-SDK'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.2'
        end
      end
    end
  end

  target 'ShopifyTests' do
    pod 'Quick', '~> 2.0'
    pod 'Nimble', '~> 8.0'
    pod 'OHHTTPStubs/Swift', '~> 7.0'
  end

end

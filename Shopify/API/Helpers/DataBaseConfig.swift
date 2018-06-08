//
//  DataBaseConfig.swift
//  Shopify
//
//  Created by Evgeniy Antonov on 6/7/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import CoreStore

public class DataBaseConfig {
    class func setup(inMemoryStore: Bool = false) {
        CoreStore.defaultStack = DataStack(
            CoreStoreSchema(
                modelVersion: "",
                entities: [
                    Entity<CartProductEntity>("CartProductEntity"),
                    Entity<CategoryEntity>("CategoryEntity"),
                    Entity<ImageEntity>("ImageEntity"),
                    Entity<PolicyEntity>("PolicyEntity"),
                    Entity<PrivacyPolicyEntity>("PrivacyPolicyEntity"),
                    Entity<ProductEntity>("ProductEntity"),
                    Entity<ProductOptionEntity>("ProductOptionEntity"),
                    Entity<ProductVariantEntity>("ProductVariantEntity"),
                    Entity<RefundPolicyEntity>("RefundPolicyEntity"),
                    Entity<ShopEntity>("ShopEntity"),
                    Entity<TermsOfServiceEntity>("TermsOfServiceEntity"),
                    Entity<VariantOptionEntity>("VariantOptionEntity")
                ],
                versionLock: [
                    "CartProductEntity": [0x1429c83e9b807e03, 0x49fbb8df7e15a1cb, 0x915cd70025e55fe5, 0x33cd5ecbdceaf215],
                    "CategoryEntity": [0x8bd033437f9133fd, 0x6e549f9f19988ecb, 0x46d3fa4fe919bc7d, 0x6184bf7cb430b2cd],
                    "ImageEntity": [0x667ec2d3c7aad435, 0x6cec8fb1262e4fb9, 0xf609dd0cc9b78ae1, 0xf5298a809455bb32],
                    "PolicyEntity": [0x30b5a342b4ca7e98, 0x152a477725ad54c7, 0x60f3b5ff898e8191, 0xbd3c034d545703e0],
                    "PrivacyPolicyEntity": [0x807c060c624e617d, 0xff39467b6f6f6292, 0x739dfc8e07b2bec1, 0xdef21c8995505f6e],
                    "ProductEntity": [0x1db237bf0f93437d, 0xf115129df8cd777b, 0x4d42ce676a85cdca, 0xb3212960fb23f313],
                    "ProductOptionEntity": [0xc26960afb4603f0b, 0x96cbdee06ba0012c, 0x8e60f84bca479085, 0x2439e3e8a1b5b7bf],
                    "ProductVariantEntity": [0x502bfa3284492762, 0x3944265f4fbf27fb, 0x712bf838c38641c5, 0x6ec8a8456a26e7f6],
                    "RefundPolicyEntity": [0xa260fb2b7b7df327, 0x245cbb5a7694de17, 0xd0fc81aba71d1531, 0xd5a267b51422a52b],
                    "ShopEntity": [0xa401c81bb31d97ed, 0xb86268baab45bb8e, 0xbd0275519619cc88, 0xe583324995ae9a5d],
                    "TermsOfServiceEntity": [0x5d3a002acf5f0b67, 0xa0732eb47f0fc06a, 0xa59bb4a45ed0c82d, 0xdb006a548e0c7ad5],
                    "VariantOptionEntity": [0xbb978e1e3eec8d64, 0xc4ff64d612a2dcba, 0xc7dbdb30a68d8ca1, 0xaf98d5a5bb2cb2c]
                ]
            )
        )
        
        do {
            if inMemoryStore {
                try CoreStore.addStorageAndWait(
                    InMemoryStore()
                )
            } else {
                try CoreStore.addStorageAndWait()
            }
        } catch {
            print(error)
        }
    }
}

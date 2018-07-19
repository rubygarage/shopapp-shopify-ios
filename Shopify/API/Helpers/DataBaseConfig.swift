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
                    "CartProductEntity": [0x38f1d79e0867b9da, 0x64f9f71851b1be80, 0x9f91b65a362560b9, 0x38657b4d09d040b7],
                    "CategoryEntity": [0x90a34ace7e3e3085, 0x5a635c1902adc1fe, 0xec6653da93594aa4, 0xdd5043b0d2e419e7],
                    "ImageEntity": [0x3bfbc9403669a347, 0x4909c9468f2df0b1, 0x201242d7e9265abb, 0x3495fd0032f3984f],
                    "PolicyEntity": [0x30b5a342b4ca7e98, 0x152a477725ad54c7, 0x60f3b5ff898e8191, 0xbd3c034d545703e0],
                    "PrivacyPolicyEntity": [0x807c060c624e617d, 0xff39467b6f6f6292, 0x739dfc8e07b2bec1, 0xdef21c8995505f6e],
                    "ProductEntity": [0x82b430d5861d21f2, 0x778f3814dc97cc00, 0xf93016575f78691f, 0x38fb2d27ac1278da],
                    "ProductOptionEntity": [0xc26960afb4603f0b, 0x96cbdee06ba0012c, 0x8e60f84bca479085, 0x2439e3e8a1b5b7bf],
                    "ProductVariantEntity": [0xb5016870de4810bf, 0x3e1246cb55d1a1b2, 0x4d25352073148255, 0x9429f28d153b6017],
                    "RefundPolicyEntity": [0xa260fb2b7b7df327, 0x245cbb5a7694de17, 0xd0fc81aba71d1531, 0xd5a267b51422a52b],
                    "ShopEntity": [0xd145e7fe3fd5ead9, 0x83426e116824f36d, 0x102b5827be76ef8b, 0xf99b49f49a666524],
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

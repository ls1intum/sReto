//
//  DummyModule.swift
//  sReto
//
//  Created by Julian Asamer on 18/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyModule: NSObject, Module {
    let advertiser: Advertiser
    let browser: Browser
    
    init(networkInterface: DummyNetworkInterface) {
        self.advertiser = DummyAdvertiser(networkInterface: networkInterface)
        self.browser = DummyBrowser(networkInterface: networkInterface)
    }
}
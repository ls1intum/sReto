//
//  DummyModule.swift
//  sReto
//
//  Created by Julian Asamer on 18/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyModule: Module {
    
    init(networkInterface: DummyNetworkInterface) {
        let advertiser = DummyAdvertiser(networkInterface: networkInterface)
        let browser = DummyBrowser(networkInterface: networkInterface)
        super.init(advertiser: advertiser, browser: browser)
    }
}
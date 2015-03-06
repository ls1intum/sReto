//
//  DummyNetworkInterface.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyNetworkInterface {
    let interfaceName: String
    var browsers: Set<DummyBrowser> = []
    var advertisers: Set<DummyAdvertiser> = []
    let recommendedPacketSize: Int = 1024
    let cost: Int

    init(interfaceName: String, cost: Int) {
        self.interfaceName = interfaceName
        self.cost = cost
    }
    
    func register(browser: DummyBrowser) {
        browsers += browser
        for advertiser in advertisers { self.notifyAddPeer(browser, advertiser) }
    }
    func unregister(browser: DummyBrowser) {
        browsers -= browser
        for advertiser in advertisers { self.notifyRemovePeer(browser, advertiser) }
    }
    
    func register(advertiser: DummyAdvertiser) {
        advertisers += advertiser
        for browser in browsers { self.notifyAddPeer(browser, advertiser) }
    }
    func unregister(advertiser: DummyAdvertiser) {
        advertisers -= advertiser
        for browser in browsers { self.notifyRemovePeer(browser, advertiser) }
    }
    
    func notifyAddPeer(browser: DummyBrowser, _ advertiser: DummyAdvertiser) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            browser.onAddPeer(advertiser.identifier, address: DummyAddress(networkInterface: self, advertiser: advertiser))
        })
    }
    func notifyRemovePeer(browser: DummyBrowser, _ advertiser: DummyAdvertiser) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            browser.onRemovePeer(advertiser.identifier)
        })
    }
}
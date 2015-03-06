//
//  DefaultRouter.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** A DefaultRouter uses Reto Modules to discover other peers. */
class DefaultRouter: Router, AdvertiserDelegate, BrowserDelegate {
    let advertiser: CompositeAdvertiser
    let browser: CompositeBrowser
    var modules: [ManagedModule]
    
    init(localIdentifier: UUID, dispatchQueue: dispatch_queue_t, modules: [Module]) {
        self.modules = modules.map { ManagedModule(module: $0, dispatchQueue: dispatchQueue) }
        self.advertiser = CompositeAdvertiser(advertisers: self.modules.map { $0.advertiser })
        self.browser = CompositeBrowser(browsers: self.modules.map { $0.browser })
        
        super.init(identifier: localIdentifier, dispatchQueue: dispatchQueue)

        self.advertiser.advertiserDelegate = self
        self.browser.browserDelegate = self
    }
    
    func start() {
        self.advertiser.startAdvertising(self.identifier)
        self.browser.startBrowsing()
    }
    func stop() {
        self.advertiser.stopAdvertising()
        self.browser.stopBrowsing()
    }
    
    func addModule(module: Module) {
        let newModule = ManagedModule(module: module, dispatchQueue: self.dispatchQueue)
        
        self.advertiser.addAdvertiser(newModule.advertiser)
        self.browser.addBrowser(newModule.browser)
        self.modules.append(newModule)
    }
    func removeModule(module: Module) {
        let removedModules = self.modules.filter { $0.module === module }
        
        for removedModule in removedModules {
            self.advertiser.removeAdvertiser(removedModule.advertiser)
            self.browser.removeBrowser(removedModule.browser)
        }
        
        self.modules = self.modules.filter { $0.module !== module }
    }
    
    func didStartAdvertising(advertiser: Advertiser) {}
    func didStopAdvertising(advertiser: Advertiser) {}
    func handleConnection(advertiser: Advertiser, connection underlyingConnection: UnderlyingConnection) {
        self.handleDirectConnection(underlyingConnection)
    }
    func didStartBrowsing(browser: Browser) {}
    func didStopBrowsing(browser: Browser) {}
    func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID) {
        self.addAddress(identifier, address: address)
    }
    func didRemoveAddress(browser: Browser, address: Address, identifier: UUID) {
        self.removeAddress(identifier, address: address)
    }
}

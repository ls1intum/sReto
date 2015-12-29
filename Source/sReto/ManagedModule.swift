//
//  ModuleManager.swift
//  sReto
//
//  Created by Julian Asamer on 13/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* A ManagedModule wraps a Modules browser and advertiser in their Managed classes, which automatically restart them if starting fails.
* */
class ManagedModule: Module {
    let module: Module

    override var description: String {
        return "ManagedModule: {\n\tadvertiser: \(self.advertiser), \n\tbrowser: \(self.browser)"
    }
    
    init(module: Module, dispatchQueue: dispatch_queue_t) {
        self.module = module
        let advertiser = ManagedAdvertiser(advertiser: module.advertiser, dispatchQueue: dispatchQueue)
        let browser = ManagedBrowser(browser: module.browser, dispatchQueue: dispatchQueue)
        module.dispatchQueue = dispatchQueue
    
        super.init(advertiser: advertiser, browser: browser)
    }
}

/**
* A ManagedAdvertiser automatically attempts to restart an Advertiser if starting the advertiser failed. The same concept applies to stopping the advertiser.
* */
class ManagedAdvertiser: NSObject, Advertiser, AdvertiserDelegate {
    let advertiser: Advertiser
    var startStopManager: StartStopHelper?
    var advertisedUuid: UUID? = nil
    
    var advertiserDelegate: AdvertiserDelegate?
    var isAdvertising: Bool { get { return self.advertiser.isAdvertising } }
    
    override var description: String {
        return "ManagedAdvertiser: {isStarted: \(self.startStopManager?.isStarted), advertiser: \(advertiser)}"
    }
    
    init(advertiser: Advertiser, dispatchQueue: dispatch_queue_t) {
        self.advertiser = advertiser
        
        super.init()
        
        self.advertiser.advertiserDelegate = self
        self.startStopManager = StartStopHelper(
            startBlock: {
                [unowned self]
                attemptNumber in
                if let uuid = self.advertisedUuid {
                    if attemptNumber != 0 {
                        log(.Low, info: "Trying to restart advertiser: \(advertiser). (Attempt #\(attemptNumber))")
                    }
                    advertiser.startAdvertising(uuid)
                }
            },
            stopBlock: {
                attemptNumber in
                if attemptNumber != 0 {
                    log(.Low, info: "Trying to stop advertiser again: \(advertiser). (Attempt #\(attemptNumber))")
                }
                advertiser.stopAdvertising()
            },
            timerSettings: (initialInterval: 5, backOffFactor: 2, maximumDelay: 60),
            dispatchQueue: dispatchQueue
        )
    }
    
    func startAdvertising(identifier: UUID) {
        self.advertisedUuid = identifier
        self.startStopManager?.start()
    }
    
    func stopAdvertising() {
        self.startStopManager?.stop()
    }
    
    // - MARK: AdvertiserDelegate
    func didStartAdvertising(advertiser: Advertiser) {
        self.startStopManager?.confirmStartOccured()
        log(.Low, info: "Started advertisement using \(advertiser)")
        self.advertiserDelegate?.didStartAdvertising(self)
    }
    
    func didStopAdvertising(advertiser: Advertiser) {
        self.startStopManager?.confirmStopOccured()
        self.advertiserDelegate?.didStopAdvertising(self)
    }
    
    func handleConnection(advertiser: Advertiser, connection: UnderlyingConnection) {
        self.advertiserDelegate?.handleConnection(self, connection: connection)
    }
}

/**
* A ManagedBrowser automatically attempts to restart a Browser if starting the browser failed. The same concept applies to stopping the Browser.
* */
class ManagedBrowser: NSObject, Browser, BrowserDelegate {
    let browser: Browser
    var browserDelegate: BrowserDelegate?
    var startStopManager: StartStopHelper?
    var isBrowsing: Bool { get { return self.browser.isBrowsing } }
    
    override var description: String {
        return "ManagedBrowser: {isStarted: \(self.startStopManager?.isStarted), browser: \(self.browser)"
    }

    init(browser: Browser, dispatchQueue: dispatch_queue_t) {
        self.browser = browser
        
        super.init()
        
        self.browser.browserDelegate = self
        self.startStopManager = StartStopHelper(
            startBlock: {
                [unowned self]
                attemptNumber in
                if attemptNumber != 0 {
                    log(.Low, info: "Trying to restart browser: \(self.browser). (Attempt #\(attemptNumber))")
                }
                self.browser.startBrowsing()
            },
            stopBlock: {
                [unowned self]
                attemptNumber in
                if attemptNumber != 0 {
                    log(.Low, info: "Trying to stop browser again: \(self.browser). (Attempt #\(attemptNumber))")
                }
                self.browser.stopBrowsing()
            },
            timerSettings: (initialInterval: 5, backOffFactor: 2, maximumDelay: 60),
            dispatchQueue: dispatchQueue
        )
    }
    
    func startBrowsing() {
        self.startStopManager?.start()
    }
    func stopBrowsing() {
        self.startStopManager?.stop()
    }
    
    func didStartBrowsing(browser: Browser) {
        self.startStopManager?.confirmStartOccured()
        self.browserDelegate?.didStartBrowsing(self)
        log(.Low, info: "Started browsing using \(browser)")
    }
    
    func didStopBrowsing(browser: Browser) {
        self.startStopManager?.confirmStopOccured()
        self.browserDelegate?.didStopBrowsing(self)
    }
    
    func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID) {
        self.browserDelegate?.didDiscoverAddress(self, address: address, identifier: identifier)
    }
    
    func didRemoveAddress(browser: Browser, address: Address, identifier: UUID) {
        self.browserDelegate?.didRemoveAddress(self, address: address, identifier: identifier)
    }
}

//
//  CompositeBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 22/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** A CompositeBrowser combines multiple Reto Browsers into a single one. */
class CompositeBrowser: NSObject, Browser, BrowserDelegate {
    var browserDelegate : BrowserDelegate?
    var isBrowsing : Bool = false
    
    var browsers: [Browser] = []
    
    init(browsers: [Browser]) {
        self.browsers = browsers

        super.init()
        
        for browser in self.browsers { browser.browserDelegate = self }
    }
    
    func addBrowser(browser: Browser) {
        self.browsers.append(browser)
        if self.isBrowsing { browser.startBrowsing() }
    }
    func removeBrowser(browser: Browser) {
        self.browsers = self.browsers.filter({ $0 === browser} )
        browser.stopBrowsing()
    }
    
    func startBrowsing() {
        self.isBrowsing = true
        
        for browser in self.browsers { browser.startBrowsing() }
    }
    func stopBrowsing() {
        self.isBrowsing = false
        
        for browser in self.browsers { browser.stopBrowsing() }
    }
    
    func didStartBrowsing(browser: Browser) {
        if self.browsers.map({ !$0.isBrowsing }).reduce(true, { $0 && $1 }) {
            self.browserDelegate?.didStopBrowsing(self)
        }
    }
    func didStopBrowsing(browser: Browser) {
        if self.browsers.map({ $0.isBrowsing }).reduce(true, { $0 && $1 }) {
            self.browserDelegate?.didStopBrowsing(self)
        }
    }
    func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID) {
        self.browserDelegate?.didDiscoverAddress(self, address: address, identifier: identifier)
    }
    func didRemoveAddress(browser: Browser, address: Address, identifier: UUID) {
        self.browserDelegate?.didRemoveAddress(self, address: address, identifier: identifier)
    }
}
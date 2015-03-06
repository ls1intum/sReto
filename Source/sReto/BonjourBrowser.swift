//
//  BonjourBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

protocol BonjourServiceBrowserDelegate : class {
    func foundAddress(identifier: UUID, addressInformation: AddressInformation)
    func removedAddress(identifier: UUID)
    func didStart()
    func didStop()
}
protocol BonjourServiceBrowser : class {
    /* weak */ var delegate: BonjourServiceBrowserDelegate? { get set }
    
    func startBrowsing(networkType: String)
    func stopBrowsing()
}

class BonjourBrowser: NSObject, Browser, BonjourServiceBrowserDelegate {
    let browser: BonjourServiceBrowser
    let networkType: String
    let dispatchQueue: dispatch_queue_t
    let recommendedPacketSize: Int
    var addresses: [UUID: (Address, Int)] = [:] // Todo: WTF-Style fix for Swift-Bug. Storing addresses does not work when not wrapping in a pointless tuple

    var browserDelegate: BrowserDelegate?
    var isBrowsing: Bool = false
    
    init(networkType: String, dispatchQueue: dispatch_queue_t, browser: BonjourServiceBrowser, recommendedPacketSize: Int) {
        self.networkType = networkType
        self.dispatchQueue = dispatchQueue
        self.browser = browser
        self.recommendedPacketSize = recommendedPacketSize
    }
    
    func startBrowsing() {
        if !self.isBrowsing {
            self.browser.delegate = self
            self.browser.startBrowsing(self.networkType)
        }
    }
    func stopBrowsing() {
        self.isBrowsing = false
        self.browser.stopBrowsing()
    }
    
    func didStart() {
        self.isBrowsing = true
        self.browserDelegate?.didStartBrowsing(self)
    }
    func didStop() {
        self.isBrowsing = false
        self.browserDelegate?.didStopBrowsing(self)
    }
    func foundAddress(identifier: UUID, addressInformation: AddressInformation) {
        let address = TcpIpAddress(
            dispatchQueue: self.dispatchQueue,
            address: addressInformation,
            recommendedPacketSize: self.recommendedPacketSize
        )
        self.addresses[identifier] = (address, 1)
        self.browserDelegate?.didDiscoverAddress(self, address: address, identifier: identifier)
    }
    func removedAddress(identifier: UUID) {
        let addr = self.addresses[identifier]
        self.addresses[identifier] = nil

        if let addr = addr {
            self.browserDelegate?.didRemoveAddress(self, address: addr.0, identifier: identifier)
        }
    }
}

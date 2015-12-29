//
//  WlanBonjourServiceBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class WlanBonjourServiceBrowser: NSObject, BonjourServiceBrowser, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    weak var delegate: BonjourServiceBrowserDelegate?
    var browser: NSNetServiceBrowser?
    var resolvingServices: [NSNetService] = []
    
    func startBrowsing(networkType: String) {
        let browser = NSNetServiceBrowser()
        self.browser = browser
        browser.delegate = self
        browser.searchForServicesOfType(networkType, inDomain: "")
    }
    
    func stopBrowsing() {
        if let browser = self.browser {
            browser.stop()
            browser.delegate = nil
            self.browser = nil
        }
        
        self.delegate?.didStop()
    }
    
    func addAddress(netService: NSNetService) {
        if let addresses = netService.addresses {
           log(.Low, info: "found address for: \(netService.name), there are \(addresses.count ?? 0) addresses available.")
            if let uuid = UUIDfromString(netService.name) {
                let addressInformation = AddressInformation.AddressAsData(addresses[0] as NSData, netService.hostName!, netService.port)
                self.delegate?.foundAddress(uuid, addressInformation: addressInformation)
            }
        }
    }
    
    func netServiceBrowserWillSearch(netServiceBrowser: NSNetServiceBrowser) {
        self.delegate?.didStart()
    }
    
    func netServiceBrowserDidStopSearch(netServiceBrowser: NSNetServiceBrowser) {
        self.delegate?.didStop()
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didFindService netService: NSNetService, moreComing: Bool) {
        if ((netService.addresses?.count ?? 0) != 0) {
            self.addAddress(netService)
        } else {
            netService.delegate = self
            self.resolvingServices.append(netService)
            netService.resolveWithTimeout(5)
        }
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didRemoveService netService: NSNetService, moreComing: Bool) {
        netService.delegate = nil
        if let uuid = UUIDfromString(netService.name) {
            self.delegate?.removedAddress(uuid)
        }
    }
    
    func netServiceDidResolveAddress(netService: NSNetService) {
        if (netService.addresses?.count ?? 0) != 0 {
            netService.delegate = nil
            self.addAddress(netService)
        } else {
            log(.Low, info: "no addresses found.")
        }
    }
    
    func netService(netService: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        netService.delegate = nil
        log(.High, error: "Could not resolve net service. (\(errorDict))")
    }
}

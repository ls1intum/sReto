//
//  WlanBonjourServiceBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class WlanBonjourServiceBrowser: NSObject, BonjourServiceBrowser, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    /*weak*/ var delegate: BonjourServiceBrowserDelegate?
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
           // print("found address for: \(netService.name), there are \(addresses.count ?? 0) addresses available.")
            if let uuid = UUIDfromString(netService.name) {
                let addressInformation = AddressInformation.AddressAsData(addresses[0] as NSData, netService.port)
                self.delegate?.foundAddress(uuid, addressInformation: addressInformation)
            }
        }
    }
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.delegate?.didStart()
    }
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.delegate?.didStop()
    }
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if ((aNetService.addresses?.count ?? 0) != 0) {
            self.addAddress(aNetService)
        } else {
            aNetService.delegate = self
            self.resolvingServices.append(aNetService)
            aNetService.resolveWithTimeout(5)
        }
    }
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        aNetService.delegate = nil
        if let uuid = UUIDfromString(aNetService.name) {
            self.delegate?.removedAddress(uuid)
        }
    }
    func netServiceDidResolveAddress(sender: NSNetService) {
        if (sender.addresses?.count ?? 0) != 0 {
            sender.delegate = nil
            self.addAddress(sender)
        } else {
            print("no addresses found.")
        }
    }
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        sender.delegate = nil
        print("Could not resolve net service. (\(errorDict))");
    }
}

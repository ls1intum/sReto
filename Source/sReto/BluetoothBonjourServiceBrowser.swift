//
//  BluetoothBonjourServiceBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class BluetoothBonjourServiceBrowser: NSObject, BonjourServiceBrowser, DNSSDBrowserDelegate, DNSSDServiceDelegate {
    var delegate: BonjourServiceBrowserDelegate?
    var browser: DNSSDBrowser?
    var services: [DNSSDService] = []
    
    func startBrowsing(networkType: String) {
        let browser = DNSSDBrowser(domain: "", type: networkType)
        self.browser = browser
        browser.delegate = self
        browser.startBrowse()
    }
    
    func stopBrowsing() {
        if let browser = self.browser {
            browser.stop()
            browser.delegate = nil
            self.browser = nil
        }
        
        self.delegate?.didStop()
    }
    
    func addAddress(service: DNSSDService) {
        log(.Low, info: "found address for: \(service.name)")
        if let uuid = UUIDfromString(service.name) {
            let addressInformation = AddressInformation.HostName(service.resolvedHost, Int(service.resolvedPort))
            self.delegate?.foundAddress(uuid, addressInformation: addressInformation)
        }
    }
    
    func dnssdBrowserWillBrowse(browser: DNSSDBrowser!) {
        self.delegate?.didStart()
    }
    
    func dnssdBrowserDidStopBrowse(browser: DNSSDBrowser!) {
        self.delegate?.didStop()
    }
    
    func dnssdBrowser(browser: DNSSDBrowser!, didAddService service: DNSSDService!, moreComing: Bool) {
        if (service.resolvedHost != nil) {
            self.addAddress(service)
        } else {
            self.services.append(service)
            service.delegate = self
            service.startResolve()
        }
    }
    
    func dnssdBrowser(browser: DNSSDBrowser!, didRemoveService service: DNSSDService!, moreComing: Bool) {
        self.services = self.services.filter({ s in s != service })
        if let uuid = UUIDfromString(service.name) {
            self.delegate?.removedAddress(uuid)
        }
    }
    
    func dnssdServiceDidResolveAddress(service: DNSSDService!) {
        self.addAddress(service)
    }
    
    func dnssdService(service: DNSSDService!, didNotResolve error: NSError!) {
        log(.Medium, error: "Could not resolve service. \(error)")
    }

    func dnssdServiceDidStop(service: DNSSDService!) {
        service.delegate = nil
        self.services = self.services.filter({ s in s != service })
    }
}

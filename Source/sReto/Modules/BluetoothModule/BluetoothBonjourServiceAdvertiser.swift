//
//  BluetoothBonjourServiceAdvertiser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class BluetoothBonjourServiceAdvertiser: NSObject, BonjourServiceAdvertiser, DNSSDRegistrationDelegate {
    var delegate: BonjourServiceAdvertiserDelegate?
    var registration: DNSSDRegistration?
    
    func startAdvertising(name: String, type: String, port: UInt) {
        let registration = DNSSDRegistration(domain: "", type: type, name: name, port: port)
        self.registration = registration
        
        registration.delegate = self
        registration.start()
    }
    func stopAdvertising() {
        if let registration = self.registration {
            registration.stop()
            registration.delegate = nil
            self.registration = nil
        }
        
        self.delegate?.didStop()
    }
    
    func dnssdRegistrationDidRegister(sender: DNSSDRegistration!) {
        log(.Low, info: "published wlan bonjour bluetooth")
        self.delegate?.didPublish()
    }
    func dnssdRegistration(sender: DNSSDRegistration!, didNotRegister error: NSError!) {
        log(.Medium, error: "failed to publish on bluetooth: \(error)")
        self.delegate?.didNotPublish()
    }
    func dnssdRegistrationDidStop(sender: DNSSDRegistration!) {
        log(.Medium, info: "stopped publishing on bluetooth")
        self.delegate?.didStop()
    }
}

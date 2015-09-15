//
//  WlanBonjourServiceAdvertiser.swift
//  sReto
//
//  Created by Julian Asamer on 25/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class WlanBonjourServiceAdvertiser: NSObject, BonjourServiceAdvertiser, NSNetServiceDelegate {
    var delegate: BonjourServiceAdvertiserDelegate?
    var netService : NSNetService?

    func startAdvertising(name: String, type: String, port: UInt) {
        let netService = NSNetService(domain: "", type: type, name: name, port: Int32(port))
        self.netService = netService
        
        netService.delegate = self
        netService.publish()
    }
    func stopAdvertising() {
        if let netService = self.netService {
            netService.stop()
            netService.delegate = nil
            self.netService = nil
        }
        
        self.delegate?.didStop()
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        //print("published wlan bonjour address: \(sender.name)")
        self.delegate?.didPublish()
    }
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        print("failed to publish on wlan: \(errorDict)")
        self.delegate?.didNotPublish()
    }
    func netServiceDidStop(sender: NSNetService){
        print("stopped publishing on wlan")
        self.delegate?.didStop()
    }
}

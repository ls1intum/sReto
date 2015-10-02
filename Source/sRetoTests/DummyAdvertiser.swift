//
//  DummyAdvertiser.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyAdvertiser: NSObject, Advertiser  {
    var isAdvertising: Bool = false
    var advertiserDelegate: AdvertiserDelegate?

    var networkInterface: DummyNetworkInterface
    var identifier: UUID = UUID_ZERO
    
    init(networkInterface: DummyNetworkInterface) {
        self.networkInterface = networkInterface
    }
    
    func startAdvertising(identifier : UUID) {
        self.identifier = identifier
        self.isAdvertising = true
        self.networkInterface.register(self)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let adv = self.advertiserDelegate {
                adv.didStartAdvertising(self)
            }
        })
    }
    func stopAdvertising() {
        self.isAdvertising = false
        self.networkInterface.unregister(self)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let adv = self.advertiserDelegate {
                adv.didStopAdvertising(self)
            }
        })
    }
    
    func onConnection(connection: DummyInConnection) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let adv = self.advertiserDelegate {
                adv.handleConnection(self, connection: connection)
            }
        })
    }
}
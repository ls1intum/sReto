//
//  CompositeAdvertiser.swift
//  sReto
//
//  Created by Julian Asamer on 22/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** A CompositeAdvertiser combines multiple Reto Advertisers into a single one. */
class CompositeAdvertiser: Advertiser, AdvertiserDelegate {
    var advertisers: [Advertiser]
    var localPeerIdentifier: UUID?
    var advertiserDelegate: AdvertiserDelegate?
    var isAdvertising: Bool = false
    
    init(advertisers: [Advertiser]) {
        self.advertisers = advertisers
        for advertiser in self.advertisers {
            advertiser.advertiserDelegate = self
        }
    }
    
    func startAdvertising(identifier: UUID) {
        self.localPeerIdentifier = identifier
        
        for advertiser in advertisers { advertiser.startAdvertising(identifier) }
        self.isAdvertising = true
    }
    
    func stopAdvertising() {
        for advertiser in advertisers { advertiser.stopAdvertising() }
    }
    
    func addAdvertiser(advertiser: Advertiser) {
        self.advertisers.append(advertiser)
        if self.isAdvertising { advertiser.startAdvertising(self.localPeerIdentifier!) }
    }
    
    func removeAdvertiser(advertiser: Advertiser) {
        self.advertisers = self.advertisers.filter({ $0 === advertiser} )
        advertiser.stopAdvertising()
    }
    
    func didStartAdvertising(advertiser: Advertiser) {
        if self.advertisers.map({ $0.isAdvertising }).reduce(true, combine: { $0 && $1 }) {
            self.advertiserDelegate?.didStartAdvertising(self)
        }
    }
    
    func didStopAdvertising(advertiser: Advertiser) {
        if self.advertisers.map({ !$0.isAdvertising }).reduce(true, combine: { $0 && $1 }) {
            self.advertiserDelegate?.didStopAdvertising(self)
        }
    }
    
    func handleConnection(advertiser: Advertiser, connection underlyingConnection: UnderlyingConnection) {
        self.advertiserDelegate?.handleConnection(self, connection: underlyingConnection)
    }
}
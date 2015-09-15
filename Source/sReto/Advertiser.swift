//
//  Advertiser.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

/**
* The AdvertiserDelegate protocol allows the Advertiser to inform its delegate about various events.
*/
public protocol AdvertiserDelegate: class {
    /** Called when the advertiser started advertising. */
    func didStartAdvertising(advertiser: Advertiser)
    /** Called when the advertiser stopped advertising. */
    func didStopAdvertising(advertiser: Advertiser)
    /** Called when the advertiser received an incoming connection from a remote peer. */
    func handleConnection(advertiser: Advertiser, connection: UnderlyingConnection)
}

/** 
* An advertiser advertises the local peer, and allows other peers to establish connections to this peer.
*/
public protocol Advertiser: class {
    /** Whether the advertiser is currently active. */
    var isAdvertising: Bool { get }
    /** The Advertiser's delegate. */
    weak var advertiserDelegate: AdvertiserDelegate? { get set }

    /** 
    * Starts advertising.
    * @param identifier A UUID identifying the local peer.
    */
    func startAdvertising(identifier : UUID)
    /**
    * Stops advertising.
    */
    func stopAdvertising()
}

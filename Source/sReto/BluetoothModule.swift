//
//  BluetoothModule.swift
//  sReto
//
//  Created by Julian Asamer on 11/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

@objc(RTBluetoothModule) public class BluetoothModule : Module {
    let networkType: String
    let recommendedPacketSize = 1024
    var dispatchQueue: dispatch_queue_t!
    
    public func setDispatchQueue(dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
    }
    
    public lazy var advertiser: Advertiser = BonjourAdvertiser(
        networkType: self.networkType,
        dispatchQueue: self.dispatchQueue,
        advertiser: BluetoothBonjourServiceAdvertiser(),
        recommendedPacketSize: self.recommendedPacketSize
    )
    public lazy var browser: Browser = BonjourBrowser(
        networkType: self.networkType,
        dispatchQueue: self.dispatchQueue,
        browser: BluetoothBonjourServiceBrowser(),
        recommendedPacketSize: self.recommendedPacketSize
    )
    
    /**
    * Constructs a new WlanModule that can be used with a LocalPeer.
    * @param type: Any ASCII string used to identify the type of application in the network. Can be anything, but should be unique for the application.
    * @param dispatchQueue: The dispatch queue used with this module. Use the same one as you used with the LocalPeer.
    */
    public init(type: String) {
        self.networkType = "_\(type)wlan._tcp."
    }
}

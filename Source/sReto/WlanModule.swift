//
//  WlanModule.swift
//  sReto
//
//  Created by Julian Asamer on 09/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
/**
* Using a WlanModule with the LocalPeer allows it to discover and connect with other peers on the local network using Bonjour.
*
* If you wish to use it, all you need to do is construct an instance and pass it to the LocalPeer either in the constructor or using the addModule method.
* */
public class WlanModule: Module {
    let networkType: String
    let recommendedPacketSize = 32*1024
    
    /**
    * Constructs a new WlanModule that can be used with a LocalPeer. 
    * @param type: Any ASCII string used to identify the type of application in the network. Can be anything, but should be unique for the application.
    * @param dispatchQueue: The dispatch queue used with this module. Use the same one as you used with the LocalPeer.
    */
    public init(type: String, dispatchQueue: dispatch_queue_t) {
        self.networkType = "_\(type)wlan._tcp."
        super.init(dispatchQueue: dispatchQueue)
        
        self.browser = BonjourBrowser(
            networkType: self.networkType,
            dispatchQueue: self.dispatchQueue,
            browser: WlanBonjourServiceBrowser(),
            recommendedPacketSize: self.recommendedPacketSize)

        self.advertiser = BonjourAdvertiser(
            networkType: self.networkType,
            dispatchQueue: self.dispatchQueue,
            advertiser: WlanBonjourServiceAdvertiser(),
            recommendedPacketSize: self.recommendedPacketSize)
    }
}

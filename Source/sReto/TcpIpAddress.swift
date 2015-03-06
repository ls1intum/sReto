//
//  TcpIpModule.swift
//  sReto
//
//  Created by Julian Asamer on 11/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class TcpIpAddress: NSObject, Address {
    let dispatchQueue: dispatch_queue_t
    let addressInformation: AddressInformation
    let recommendedPacketSize: Int
    let cost = 10
    
    init(dispatchQueue: dispatch_queue_t, address: AddressInformation, recommendedPacketSize: Int) {
        self.dispatchQueue = dispatchQueue
        self.addressInformation = address
        self.recommendedPacketSize = recommendedPacketSize
    }
    
    func createConnection() -> UnderlyingConnection {
        return AsyncSocketUnderlyingConnection(dispatchQueue: self.dispatchQueue, recommendedPacketSize: self.recommendedPacketSize, addressInformation: self.addressInformation)
    }
}


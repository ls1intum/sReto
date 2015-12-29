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
    let hostName: String
    
    init(dispatchQueue: dispatch_queue_t, address: AddressInformation, recommendedPacketSize: Int) {
        self.dispatchQueue = dispatchQueue
        self.addressInformation = address
        switch address {
        case .AddressAsData(_, let hostName, _):
            self.hostName = hostName
            break
        case .HostName(let hostName, _):
            self.hostName = hostName
            break
        }
        self.recommendedPacketSize = recommendedPacketSize
    }
    
    func createConnection() -> UnderlyingConnection {
        return AsyncSocketUnderlyingConnection(dispatchQueue: self.dispatchQueue, recommendedPacketSize: self.recommendedPacketSize, addressInformation: self.addressInformation)
    }
}


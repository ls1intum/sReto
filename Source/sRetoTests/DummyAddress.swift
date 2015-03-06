//
//  DummyAddress.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyAddress: NSObject, Address {
    let networkInterface: DummyNetworkInterface
    let advertiser: DummyAdvertiser
    var cost: Int { return networkInterface.cost }
    
    init(networkInterface: DummyNetworkInterface, advertiser: DummyAdvertiser) {
        self.networkInterface = networkInterface
        self.advertiser = advertiser
    }
    
    func createConnection() -> UnderlyingConnection {
        //let x: UnderlyingConnection? = nil
        //return x!
        return DummyOutConnection(networkInterface: networkInterface, advertiser: advertiser)
    }
}
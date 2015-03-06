//
//  Address.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

/**
* An Address encapsulates the necessary information for the peer to establish a connection to another peer.
* Addresses are generated and distributed by an Advertiser. The Advertiser also ensures that the Address is functional by accepting connections.
* These advertised Addresses can then be discovered by Browsers.
*/
@objc(RTAddress) public protocol Address {
    /** The cost of an address gives an heuristic about which Address should be used if multiple are available. Lower cost is preferred. An WlanAddress uses a cost of 10. */ 
    var cost: Int { get }
    /** 
    * Called to establish a new outgoing connection.
    * @return A new connection to the peer.
    */
    func createConnection() -> UnderlyingConnection
}
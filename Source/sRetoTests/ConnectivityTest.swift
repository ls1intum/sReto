//
//  ConnectivityTest.swift
//  sReto
//
//  Created by Julian Asamer on 20/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

/**
* Note: At this time, these tests are extremely slow in Debug settings due to Swift dictionary's terrible performance.
*/
class ConnectivityTest: XCTestCase {

    override func setUp() {
        super.setUp()
        broadcastDelaySettings = (0.01, 0.05)
        reliabilityManagerDelays = (50, 50)
    }
    
    func testDirectNeighborConnectivity() {
        testConnectivity(PeerConfiguration.directNeighborConfiguration())
    }
    func testTwoHopConnectivity() {
        testConnectivity(PeerConfiguration.twoHopRoutedConfiguration())
    }
    func testTwoHopMulticastConnectivity() {
        testConnectivity(PeerConfiguration.twoHopRoutedMulticastConfiguration())
    }
    func testTwoHopMulticastConnectivity2() {
        testConnectivity(PeerConfiguration.twoHopRoutedMulticastConfiguration2())
    }
    func testFourHopConnectivity() {
        testConnectivity(PeerConfiguration.fourHopRoutedConfiguration())
    }
    
    func testConnectivity(configuration: PeerConfiguration) {
        let activePeers = [configuration.primaryPeer]+configuration.destinations
        
        var onConnectExpectations: [UUID: XCTestExpectation] = [:]
        var onCloseExpectations: [UUID: XCTestExpectation] = [:]
        for peer in activePeers {
            onConnectExpectations[peer.identifier] = self.expectationWithDescription("\(peer.identifier) received on connect call")
            onCloseExpectations[peer.identifier] = self.expectationWithDescription("\(peer.identifier) received on close call")
        }
        
        configuration.executeAfterDiscovery {
            print("all reachable!")
            for peer in configuration.destinations {
                peer.onConnection = {
                    source, connection in
                    connection.onConnect = {
                        c in
                        onConnectExpectations[peer.identifier]?.fulfill()
                        onConnectExpectations[peer.identifier] = nil
                        
                        if onConnectExpectations.count == 0 {
                            connection.close()
                        }
                    }
                    connection.onClose = {
                        _ in
                        print("on close: \(peer.identifier)")
                        onCloseExpectations[peer.identifier]?.fulfill()
                    }
                }
            }
            
            let connection = configuration.primaryPeer.connect(Set(configuration.primaryPeer.peers.filter({ configuration.destinationIdentifiers.contains($0.identifier) })))
            
            connection.onConnect = {
                connection in
                onConnectExpectations[configuration.primaryPeer.identifier]?.fulfill()
                onConnectExpectations[configuration.primaryPeer.identifier] = nil
                if onConnectExpectations.count == 0 {
                    connection.close()
                }
            }
            connection.onClose = {
                _ in
                onCloseExpectations[configuration.primaryPeer.identifier]?.fulfill()
                ()
            }
        }
        
        self.waitForExpectationsWithTimeout(60, handler: {
            error in print("success!")
        })
    }
}

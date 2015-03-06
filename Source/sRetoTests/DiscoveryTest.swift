//
//  DiscoveryTest.swift
//  sReto
//
//  Created by Julian Asamer on 20/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

class DiscoveryTest: XCTestCase {
    override func setUp() {
        super.setUp()
        broadcastDelaySettings = (0.01, 0.05)
    }
    
    func testDiscoveryDirect() {
        self.testDiscovery(PeerConfiguration.directNeighborConfiguration())
    }
    func testDiscovery2Hop() {
        self.testDiscovery(PeerConfiguration.twoHopRoutedConfiguration())
    }
    func testDiscovery4Hop() {
        self.testDiscovery(PeerConfiguration.fourHopRoutedConfiguration())
    }
    
    func testDiscovery(configuration: PeerConfiguration) {
        let allPeersDiscoveredExpectation = self.expectationWithDescription("all peers discovered")
        var reachablePeerIdentifiers = configuration.reachablePeerIdentifiers - [configuration.primaryPeer.identifier]
        
        configuration.primaryPeer.start(
            onPeerDiscovered: {
                reachablePeerIdentifiers -= $0.identifier
                
                if reachablePeerIdentifiers.count == 0 {
                    allPeersDiscoveredExpectation.fulfill()
                }
            }, onPeerRemoved: { _ in ()}, onIncomingConnection: {_ in ()}
        )
        
        for peer in configuration.participatingPeers - [configuration.primaryPeer] {
            peer.start(onPeerDiscovered: {_ in ()}, onPeerRemoved: {_ in ()}, onIncomingConnection: {_ in ()})
        }
        
        self.waitForExpectationsWithTimeout(30, handler: { error in () })
    }
}

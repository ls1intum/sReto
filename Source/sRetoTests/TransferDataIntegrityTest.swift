//
//  TransferDataIntegrityTest.swift
//  sReto
//
//  Created by Julian Asamer on 21/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

/**
* Note: These tests are currently very slow to Swift Dictionary's terrible performance when using debug settings.
*/
class TransferDataIntegrityTest: XCTestCase {
    override func setUp() {
        super.setUp()
        broadcastDelaySettings = (0.01, 0.05)
        reliabilityManagerDelays = (50, 50)
    }
    var connection: Connection? = nil
    
    func testTransferDataIntegrityWithDirectConfiguration() {
        self.testTransferDataIntegrity(PeerConfiguration.directNeighborConfiguration())
    }
    func testTransferDataIntegrityWith2HopConfiguration() {
        self.testTransferDataIntegrity(PeerConfiguration.twoHopRoutedConfiguration())
    }
    func testTransferDataIntegrityWith2HopMulticastConfiguration() {
        self.testTransferDataIntegrity(PeerConfiguration.twoHopRoutedMulticastConfiguration())
    }
    func testTransferDataIntegrityWith2HopMulticastConfiguration2() {
        self.testTransferDataIntegrity(PeerConfiguration.twoHopRoutedMulticastConfiguration2())
    }
    func testTransferDataIntegrityWith4HopConfiguration() {
        self.testTransferDataIntegrity(PeerConfiguration.fourHopRoutedConfiguration())
    }

    func testTransferDataIntegrity(configuration: PeerConfiguration) {
        let dataLength = 10000
        
        var receivedDataExpectations: [UUID: XCTestExpectation] = [:]
        for peer in configuration.destinations {
            receivedDataExpectations[peer.identifier] = self.expectationWithDescription("\(peer.identifier) received correct data")
        }
        
        configuration.executeAfterDiscovery {
            for peer in configuration.destinations {
                peer.onConnection = {
                    (remotePeer: RemotePeer, connection: Connection) -> () in
                    connection.onTransfer = {
                        connection, transfer in
                        transfer.onCompleteData = {
                            transfer, data in
                            if TestData.verify(data, expectedLength: dataLength) {
                                receivedDataExpectations[peer.identifier]!.fulfill()
                            }
                        }
                    }
                    
                    return ()
                }
            }
            
            let destinations = Set(configuration.primaryPeer.peers.filter({ configuration.destinationIdentifiers.contains($0.identifier) }))
            self.connection = configuration.primaryPeer.connect(destinations)
            let data = TestData.generate(dataLength)
            self.connection!.send(data)
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error) -> Void in
            print("success!")
        })
    }
}

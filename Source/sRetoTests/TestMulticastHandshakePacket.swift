//
//  TestMulticastHandshakePacket.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

class TestMulticastHandshakePacket: XCTestCase {
    func testMulticastPacket() {
        let destinationIds: Set = [UUID.random(), UUID.random()]
        let hopTree: Tree = Tree(
            value: UUID.random(),
            subtrees: [
                Tree(
                    value: UUID.random(),
                    subtrees: [
                        Tree(
                            value: UUID.random(),
                            subtrees: []
                        )
                    ]
                ),
                Tree(
                    value: UUID.random(),
                    subtrees: []
                )
            ]
        )
        
        let packet1 = MulticastHandshake(sourcePeerIdentifier: UUID.random(), destinationIdentifiers: destinationIds, nextHopTree: hopTree)        
        if let packet2 = MulticastHandshake.deserialize(DataReader(packet1.serialize())) {
            XCTAssert(packet1.sourcePeerIdentifier == packet2.sourcePeerIdentifier, "sourcePeerIdentifier doesn't match.")
            XCTAssert(packet1.destinationIdentifiers == packet2.destinationIdentifiers, "Destination ids dont match.")
            XCTAssert(packet1.nextHopTree == packet2.nextHopTree, "Hop trees dont match.")
        } else {
            XCTFail("Failed to deserialize.")
        }
    }
}

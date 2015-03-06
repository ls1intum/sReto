//
//  RoutingTableTests.swift
//  sReto
//
//  Created by Julian Asamer on 20/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

func == (a: (String, Double)?, b: (String, Double)?) -> Bool {
    return a?.0 == b?.0 && a?.1 == b?.1
}

class RoutingTableTests: XCTestCase {
    
    func testRoutingTableWithNeighbor() {
        let routingTable = LinkStateRoutingTable(localNode: "Local")
        let routeChange = routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 10)
        
        XCTAssert(routeChange.nowReachable.count == 1, "New node reachable")
        XCTAssert(routeChange.nowUnreachable.count == 0, "Node unreachable")
        XCTAssert(routeChange.routeChanged.count == 0, "Node unreachable")
        
        XCTAssert(routeChange.nowReachable[0].nextHop == "A")
        XCTAssert(routeChange.nowReachable[0].cost == 10)
    }

    func testRoutingTableWithIneffectualLinkStateInformation() {
        let routingTable = LinkStateRoutingTable(localNode: "Local")
        routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 10)

        let routeChange = routingTable.getRoutingTableChangeForLinkStateInformationUpdate("B", neighbors: [(neighborId: "C", cost: 1), (neighborId: "D", cost: 1)])
        
        XCTAssert(routeChange.nowReachable.count == 0, "New node reachable")
        XCTAssert(routeChange.nowUnreachable.count == 0, "Node unreachable")
        XCTAssert(routeChange.routeChanged.count == 0, "Node unreachable")
    }

    func testRoutingTableWithEffectualLinkStateInformation() {
        let routingTable = LinkStateRoutingTable(localNode: "Local")
        routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 10)
        routingTable.getRoutingTableChangeForLinkStateInformationUpdate("B", neighbors: [(neighborId: "C", cost: 1), (neighborId: "D", cost: 1)])
        
        let routeChange = routingTable.getRoutingTableChangeForLinkStateInformationUpdate("A", neighbors: [(neighborId: "B", cost: 1)])
        
        XCTAssert(routeChange.nowReachable.count == 3, "New node reachable")
        XCTAssert(routeChange.nowUnreachable.count == 0, "Node unreachable")
        XCTAssert(routeChange.routeChanged.count == 0, "Node unreachable")
        
        var reachableDictionary: [String: (String, Double)] = [:]
        for (node, nextHop, cost) in routeChange.nowReachable { reachableDictionary[node] = (nextHop, cost) }
        XCTAssert(reachableDictionary["B"] == ("A", 11))
        XCTAssert(reachableDictionary["C"] == ("A", 12))
        XCTAssert(reachableDictionary["D"] == ("A", 12))
    }
    
    func testRoutingTableForRouteChanges() {
        let routingTable = LinkStateRoutingTable(localNode: "Local")
        routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 10)
        routingTable.getRoutingTableChangeForLinkStateInformationUpdate("B", neighbors: [(neighborId: "C", cost: 1), (neighborId: "D", cost: 1)])
        routingTable.getRoutingTableChangeForLinkStateInformationUpdate("A", neighbors: [(neighborId: "B", cost: 1)])
        
        let routeChange = routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 5)
        
        XCTAssert(routeChange.nowReachable.count == 0, "New node reachable")
        XCTAssert(routeChange.nowUnreachable.count == 0, "Node unreachable")
        XCTAssert(routeChange.routeChanged.count == 4, "Node unreachable")
    }
    
    func testRoutingTableUnreachability() {
        let routingTable = LinkStateRoutingTable(localNode: "Local")
        routingTable.getRoutingTableChangeForNeighborUpdate("A", cost: 10)
        routingTable.getRoutingTableChangeForLinkStateInformationUpdate("A", neighbors: [(neighborId: "B", cost: 1)])
        
        let routeChange = routingTable.getRoutingTableChangeForNeighborRemoval("A")
        
        XCTAssert(routeChange.nowReachable.count == 0, "New node reachable")
        XCTAssert(routeChange.nowUnreachable.count == 2, "Node unreachable")
        XCTAssert(routeChange.routeChanged.count == 0, "Node unreachable")
    }
}

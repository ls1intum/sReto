//
//  Node.swift
//  sReto
//
//  Created by Julian Asamer on 26/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* The Node class represents the routing component of a remote peer. It stores all routing related information about that peer.
* Nodes are created and managed by a Router.
* 
* Nodes also forward FloodPackets to the FloodingPacketManager which handles those packets. These packets are used to transmit routing information.
*/
class Node: Hashable, PacketHandler {
    let linkStatePacketManager: FloodingPacketManager?
    
    /** The Router that created this Node object*/
    weak var router: Router!
    /** The Node's identifer*/
    let identifier: UUID
    /** The local peer's identifier. */
    let localIdentifier: UUID
    /** Addresses that allow to connect to this node directly. */
    var directAddresses: [Address] = []
    /** Whether this node is a neighbor of the local peer. */
    var isNeighbor: Bool { get { return reachableVia?.nextHop == self } }
    /** Stores the PacketConnection used to transmit routing metadata. */
    var routingConnection: PacketConnection?
    var hashValue: Int { get { return identifier.hashValue } }
    /** Whether a route to this node exists or not. */
    var isReachable: Bool { get { return reachableVia != nil } }
    /** Of any pair of nodes that are neighbors, only one of them is responsible to establish the routingConnection, because only one is needed. This property 
    * is true for the node which is responsible for doing so. */
    var isResponsibleForEstablishingRoutingConnection: Bool {
        get {
            return self.identifier < self.localIdentifier
        }
    }
    /** Returns the best direct address available to this node, based on the know Addresses' cost heuristic. */
    var bestAddress: Address? { get { return minimum(self.directAddresses, comparator: comparing { $0.cost }) } }
    /** If a connection should be established to this node, this property stores the next hop in the optimal route, as well as the total cost to the node. */
    var reachableVia: (nextHop: Node, cost: Int)? = nil
    /** The next hop to use when establishing a connection to this node (if the optimal route should be used). */
    var nextHop: Node? { get { return reachableVia?.nextHop } }
    
    /** Initializes a Node object */
    init(identifier: UUID, localIdentifier: UUID, linkStatePacketManager: FloodingPacketManager?) {
        self.identifier = identifier
        self.localIdentifier = localIdentifier
        self.linkStatePacketManager = linkStatePacketManager
    }
    /** Adds a direct address to this node */
    func addAddress(address: Address) {
        self.directAddresses.append(address)
    }
    /** Removes a direct address from this node */
    func removeAddress(address: Address) {
        self.directAddresses = self.directAddresses.filter { $0 !== address }
    }
    
    // MARK: Routing Connections (for routing information exchange)
    func establishRoutingConnection() {
        if !self.isResponsibleForEstablishingRoutingConnection { return }
        if self.routingConnection?.isConnected ?? false { return }
        
        self.router!.establishDirectConnection(
            destination: self,
            purpose: .RoutingConnection,
            onConnection: {
                connection in
                let connectionIdentifier = randomUUID()
                let packetConnection = PacketConnection(
                    connection: connection,
                    connectionIdentifier: connectionIdentifier,
                    destinations: [self]
                )

                self.setupRoutingConnection(packetConnection)
                self.router.onNeighborReachable(self)
            },
            onFail: {
                print("Failed to establish routing connection.")
            }
        )
    }
    func handleRoutingConnection(connection: UnderlyingConnection) {
        let packetConnection = PacketConnection(connection: connection, connectionIdentifier: UUID_ZERO, destinations: [])
        self.setupRoutingConnection(packetConnection)
        self.router.onNeighborReachable(self)
    }
    func setupRoutingConnection(connection: PacketConnection) {
        self.routingConnection = connection
        connection.addDelegate(self)
        if connection.isConnected { self.underlyingConnectionDidConnect() }
    }
    func sendPacket(packet: Packet) {
        self.routingConnection?.write(packet)
    }

    // MARK: PacketConnection delegate
    let handledPacketTypes = [PacketType.FloodPacket]
    func underlyingConnectionDidClose(error: AnyObject?) {
        self.router?.onNeighborLost(self)
    }
    func willSwapUnderlyingConnection() {}
    func underlyingConnectionDidConnect() {}
    func didWriteAllPackets() {}
    func handlePacket(data: DataReader, type: PacketType) {
        self.linkStatePacketManager?.handlePacket(self.identifier, data: data, packetType: type)
    }
}

func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.identifier == rhs.identifier
}
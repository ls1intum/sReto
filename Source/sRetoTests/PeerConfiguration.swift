//
//  PeerConfiguration.swift
//  sReto
//
//  Created by Julian Asamer on 20/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class PeerConfiguration {
    let primaryPeer: LocalPeer
    let participatingPeers: Set<LocalPeer>
    let reachablePeers: Set<LocalPeer>
    let destinations: Set<LocalPeer>
    
    var reachablePeerIdentifiers: Set<UUID> { get { return reachablePeers.map { $0.identifier } } }
    var destinationIdentifiers: Set<UUID> { get { return destinations.map { $0.identifier } } }
    
    init(primaryPeer: LocalPeer, destinations: Set<LocalPeer>, participatingPeers: Set<LocalPeer>, reachablePeers: Set<LocalPeer>) {
        self.primaryPeer = primaryPeer
        self.participatingPeers = participatingPeers
        self.reachablePeers = reachablePeers
        self.destinations = destinations
    }
    convenience init(primaryPeer: LocalPeer, destinations: Set<LocalPeer>, participatingPeers: Set<LocalPeer>) {
        self.init(primaryPeer: primaryPeer, destinations: destinations, participatingPeers: participatingPeers, reachablePeers: participatingPeers)
    }
    convenience init(primaryPeer: LocalPeer, destination: LocalPeer, participatingPeers: Set<LocalPeer>, reachablePeers: Set<LocalPeer>) {
        self.init(primaryPeer: primaryPeer, destinations: [destination], participatingPeers: participatingPeers, reachablePeers: reachablePeers)
    }
    convenience init(primaryPeer: LocalPeer, destination: LocalPeer, participatingPeers: Set<LocalPeer>) {
        self.init(primaryPeer: primaryPeer, destination: destination, participatingPeers: participatingPeers, reachablePeers: participatingPeers)
    }
    
    func executeAfterDiscovery(onSuccess: () -> ()) {
        var discoveredPeers: [LocalPeer: Set<UUID>] = [:]
        
        for peer in self.participatingPeers {
            discoveredPeers[peer] = Set()
            
            peer.start(
                onPeerDiscovered: {
                    discoveredPeers[peer]! += $0.identifier
                    
                    let allDiscovered = filter(discoveredPeers, { self.reachablePeers.contains($0.0) })
                        .map({ $0.1.count == self.reachablePeers.count-1 })
                        .reduce(true, { $0 && $1 })
                    if allDiscovered { onSuccess() }
                },
                onPeerRemoved: {
                    discoveredPeers[peer]! -= $0.identifier
                },
                onIncomingConnection: {
                    (peer: RemotePeer, connection: Connection) -> () in ()
                }
            )
        }
    }
    
    class func createPeer(interfaces: [DummyNetworkInterface]) -> LocalPeer {
        return LocalPeer(
            identifier: UUID.random(),
            modules: interfaces.map({ DummyModule(networkInterface: $0) }),
            dispatchQueue: dispatch_get_main_queue()
        )
    }
    class func directNeighborConfiguration() -> PeerConfiguration {
        let interfaces = [("test1", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0]],
        ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[1]], participatingPeers: Set(peers))
    }
    
    class func twoHopRoutedConfiguration() -> PeerConfiguration {
        let interfaces = [("test1", 1), ("test2", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0], interfaces[1]],
            [interfaces[1]],
        ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[2]], participatingPeers: Set(peers))
    }
    
    class func twoHopRoutedMulticastConfiguration() -> PeerConfiguration {
        let interfaces = [("test1", 1), ("test2", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0], interfaces[1]],
            [interfaces[1]],
        ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[1], peers[2]], participatingPeers: Set(peers))
    }
    class func twoHopRoutedMulticastConfiguration2() -> PeerConfiguration {
        let interfaces = [("test1", 1), ("test2", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0], interfaces[1]],
            [interfaces[1]],
            [interfaces[1]]
        ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[2], peers[3]], participatingPeers: Set(peers))
    }
    
    class func fourHopRoutedConfiguration() -> PeerConfiguration {
        let interfaces = [("test1", 1), ("test2", 1), ("test3", 1), ("test4", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0], interfaces[1]],
            [interfaces[1], interfaces[2]],
            [interfaces[2], interfaces[3]],
            [interfaces[3]],
        ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[4]], participatingPeers: Set(peers))
    }
    class func fourHopRoutedMulticastConfiguration() -> PeerConfiguration {
        let interfaces = [("test1", 1), ("test2", 1), ("test3", 1), ("test4", 1)].map { DummyNetworkInterface(interfaceName: $0.0, cost: $0.1) }
        let peers = [
            [interfaces[0]],
            [interfaces[0], interfaces[1]],
            [interfaces[1], interfaces[2]],
            [interfaces[2], interfaces[3]],
            [interfaces[3]],
            ].map(createPeer)
        
        return PeerConfiguration(primaryPeer: peers[0], destinations: [peers[1], peers[2], peers[3], peers[4]], participatingPeers: Set(peers))
    }
}
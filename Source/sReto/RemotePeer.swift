//
//  RemotePeer.swift
//  sReto
//
//  Created by Julian Asamer on 07/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* A RemotePeer represents another peer in the network.
*
* You do not construct RemotePeer instances yourself; they are provided to you by the LocalPeer.
*
* This class can be used to establish and accept connections to/from those peers.
* */
@objc(RTRemotePeer) public class RemotePeer: NSObject {
    /** This peer's unique identifier. */
    public let identifier: UUID
    /**
    * Set this property if you want to handle incoming connections on a per-peer basis.
    */
    public var onConnection: ConnectionClosure? = nil
    
    /**
    * Establishes a connection to this peer.
    * 
    * @return A Connection to this peer.
    */
    public func connect() -> Connection {
        return self.localPeer.connect([self])
    }

    // MARK: Internal
    
    /** The node representing this peer on the routing level */
    let node: Node
    /** The LocalPeer that created this peer */
    let localPeer: LocalPeer
    /** Stores all connections established by this peer */
    var connections: [UUID: PacketConnection] = [:]
    
    /**
    * Private initializer. See the class documentation about how to obtain RemotePeer instances.
    * @param node The node representing the the peer on the routing level.
    * @param localPeer The local peer that created this peer
    */
    init(node: Node, localPeer: LocalPeer, dispatchQueue: dispatch_queue_t) {
        self.node = node
        self.localPeer = localPeer
        self.identifier = node.identifier
    }
}
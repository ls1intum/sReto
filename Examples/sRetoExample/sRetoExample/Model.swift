//
//  Model.swift
//  sRetoExample
//
//  Created by Julian Asamer on 24/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import sReto

class Model {
    var peers: [ExamplePeer] = []
    var selectedPeer: ExamplePeer?
    
    init() {}
    
    func addPeer(peer: RemotePeer) {
        self.peers.append(ExamplePeer(peer: peer))
    }
    func removePeer(peer: RemotePeer) {
        print("removing: \(peer), existing: \(peer)")
        self.peers = self.peers.filter({ existingPeer in existingPeer.peer !== peer})
        if self.selectedPeer === peer { self.selectedPeer = nil }
    }
    func selectPeer(index: Int) {
        self.selectedPeer = peers[index]
    }
    func examplePeer(peer: RemotePeer) -> ExamplePeer? {
        print("peers here: \(self.peers)", terminator: "")
        for epeer in self.peers { if epeer.peer === peer { return epeer } }
        return nil
    }
    func examplePeer(connection: Connection) -> ExamplePeer? {
        for epeer in self.peers {
            for econnection in epeer.connections {
                if econnection.connection === connection { return epeer }
            }
        }
        return nil
    }
    func exampleConnection(connection: Connection) -> ExampleConnection? {
        for epeer in self.peers {
            for econnection in epeer.connections {
                if econnection.connection === connection { return econnection }
            }
        }
        return nil
    }
}

class ExamplePeer {
    let peer: RemotePeer
    var connections: [ExampleConnection] = []
    var selectedConnection: ExampleConnection? = nil
    
    init(peer: RemotePeer) {
        self.peer = peer
    }
    
    func selectConnection(index: Int) {
        self.selectedConnection = self.connections[index]
    }
    func addConnection(connection: Connection) {
        self.connections.append(ExampleConnection(connection: connection))
    }
    func removeConnection(connection: Connection) {
        self.connections = self.connections.filter({ existingConnection in existingConnection.connection !== connection })
        if connection === self.selectedConnection { self.selectedConnection = nil }
    }
}

class ExampleConnection {
    let description: String
    let connection: Connection
    var transfers: [Transfer]?
    var inTransfer: InTransfer?
    var outTransfer: Transfer?
    var previousInTransferText: String = ""
    var previousOutTransferText: String = ""
    
    init(connection: Connection) {
        self.connection = connection
        self.description = NSDate().description
    }
}
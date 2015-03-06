//
//  LinkStatePacket.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* A LinkState packet represents a peer's link state, i.e. a list of all of it's neighbors and the cost associated with reaching them.
*/
struct LinkStatePacket: Packet {
    /** The identifier of the peer that generated the packet. */
    let peerIdentifier: UUID
    /** A list of identifier/cost pairs for each of the peer's neighbors. */
    let neighbors: [(identifier: UUID, cost: Int32)]
    
    static func getType() -> PacketType { return PacketType.LinkState }
    static func getLength() -> Int { return sizeof(PacketType) + sizeof(UUID) }
    
    static func deserialize(data: DataReader) -> LinkStatePacket? {
        if !Packets.check(data: data, expectedType: self.getType(), minimumLength: self.getLength()) { return nil }
        
        let peerIdentifier = data.getUUID()
        var neighbors: [(identifier: UUID, cost: Int32)] = []
        let neighborCount: Int = Int(data.getInteger())
        
        if !data.checkRemaining(neighborCount * (sizeof(UUID) + sizeof(Int32))) {
            log(.High, error: "not enough data remaining in LinkStatePacket.")
            return nil
        }
        
        for index in 0..<neighborCount {
            neighbors.append((identifier: data.getUUID(), cost: data.getInteger()))
        }
        
        return LinkStatePacket(peerIdentifier: peerIdentifier, neighbors: neighbors)
    }
    
    func serialize() -> NSData {
        let data = DataWriter(length: self.dynamicType.getLength() + self.neighbors.count * (sizeof(UUID) + sizeof(Int32)))
        data.add(self.dynamicType.getType().rawValue)
        data.add(self.peerIdentifier)
        data.add(Int32(self.neighbors.count))
        
        for (identifier, cost) in self.neighbors {
            data.add(identifier)
            data.add(cost)
        }
        
        return data.getData()
    }
}
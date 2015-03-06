//
//  RemoteP2PPacket.swift
//  sReto
//
//  Created by Julian Asamer on 07/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation


enum RemoteP2PPacketType: Int32 {
    case StartAdvertisement = 1
    case StopAdvertisement = 2
    case StartBrowsing = 3
    case StopBrowsing = 4
    case PeerAdded = 5
    case PeerRemoved = 6
    case ConnectionRequest = 7
}

struct RemoteP2PPacket {
    let type: RemoteP2PPacketType
    let identifier: UUID
    
    static func fromData(data: DataReader) -> RemoteP2PPacket? {
        let type = RemoteP2PPacketType(rawValue: data.getInteger())
        if type == nil { return nil }
        if !data.checkRemaining(16) { return nil }
        
        return RemoteP2PPacket(type: type!, identifier: data.getUUID())
    }
    
    func serialize() -> NSData {
        let data = DataWriter(length: 20)
        data.add(self.type.rawValue)
        data.add(self.identifier)
        return data.getData()
    }
}
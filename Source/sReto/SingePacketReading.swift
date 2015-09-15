//
//  SingePacketReading.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* Reads a single packet from an underlying connection asynchronously.
* @param connection The connection from which to read the data from.
* @param packetHandler A closure to call when the data was received.
* @param failBlock A closure to call when reading the packet failed for any reason.
*/
func readSinglePacket(connection connection: UnderlyingConnection, onPacket packetHandler: (DataReader) -> (), onFail failBlock: () -> ()) {
    readPackets(connection: connection, packetCount: 1, onPacket: packetHandler, onSuccess: {}, onFail: failBlock)
}

/**
* Reads a fixed number of packets from an underlying connection.
* @param connection The connection from which to read the data from.
* @param packetCount The number of packets to read.
* @param packetHandler A closure call whenever a packet is received. Is called packetCount times if successfull.
* @param onSuccess A closure to call when the specified number of packets was received.
* @param failBlock A closure to call when reading the packets failed for any reason.
*/
func readPackets(connection connection: UnderlyingConnection, packetCount: Int, onPacket packetHandler: (DataReader) -> (), onSuccess successBlock: () -> (), onFail failBlock: () -> ()) {
    SinglePacketReader(connection: connection, packetCount: packetCount, onPacket: packetHandler, onSuccess: successBlock, onFail: failBlock)
}
class SinglePacketReader: NSObject, UnderlyingConnectionDelegate {
    var underlyingConnection: UnderlyingConnection?
    let packetCount: Int
    let packetHandler: (DataReader) -> ()
    let successBlock: () -> ()
    let failBlock: () -> ()
    var packetsReceived = 0
    init(connection: UnderlyingConnection, packetCount: Int, onPacket packetHandler: (DataReader) -> (), onSuccess successBlock: () -> (), onFail failBlock: () -> ()) {
        self.underlyingConnection = connection
        self.packetCount = packetCount
        self.packetHandler = packetHandler
        self.failBlock = failBlock
        self.successBlock = successBlock
        
        super.init()
        connection.delegate = self
    }
    
    func didConnect(connection: UnderlyingConnection) {}
    func didClose(connection: UnderlyingConnection, error: AnyObject?) {
        self.underlyingConnection?.delegate = nil
        self.underlyingConnection = nil
        self.failBlock()
    }
    func didReceiveData(connection: UnderlyingConnection, data: NSData) {
        self.packetsReceived++
        
        if self.packetsReceived == self.packetCount { underlyingConnection?.delegate = nil }
        
        self.packetHandler(DataReader(data))
        
        if self.packetsReceived == self.packetCount {
            self.underlyingConnection = nil
            self.successBlock()
        }
    }
    func didSendData(connection: UnderlyingConnection) {}
}

/**
* Writes a single packet to an underlying connection.
*
* @param connection The connection to write the data to.
* @param packet The packet to write.
* @param successBlock A closure to call when the packet was written successfully.
* @param failBlock A closure to call when sending the data failed for any reason.
*/
func writeSinglePacket(connection connection: UnderlyingConnection, packet: Packet, onSuccess successBlock: () -> (), onFail failBlock: () -> ()) {
    SinglePacketWriter(connection: connection, packet: packet, successBlock: successBlock, failBlock: failBlock)
}

class SinglePacketWriter: NSObject, UnderlyingConnectionDelegate {
    var underlyingConnection: UnderlyingConnection?
    let successBlock: () -> ()
    let failBlock: () -> ()
    let packet: Packet
    
    init(connection: UnderlyingConnection, packet: Packet, successBlock: () -> (), failBlock: () -> ()) {
        self.underlyingConnection = connection
        self.successBlock = successBlock
        self.failBlock = failBlock
        self.packet = packet
        
        super.init()
        
        connection.delegate = self
        if connection.isConnected { self.underlyingConnection?.writeData(packet.serialize()) }
    }
    
    func didConnect(connection: UnderlyingConnection) {
        self.underlyingConnection?.writeData(packet.serialize())
    }
    func didClose(connection: UnderlyingConnection, error: AnyObject?) {
        self.underlyingConnection?.delegate = nil
        self.underlyingConnection = nil
        self.failBlock()
    }
    func didReceiveData(connection: UnderlyingConnection, data: NSData) {}
    func didSendData(connection: UnderlyingConnection) {
        self.underlyingConnection?.delegate = nil
        self.underlyingConnection = nil
        self.successBlock()
    }
}

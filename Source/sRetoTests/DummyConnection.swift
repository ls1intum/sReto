//
//  DummyConnection.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyConnection: NSObject, UnderlyingConnection {
    var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool = false
    var recommendedPacketSize: Int { get { return self.networkInterface.recommendedPacketSize } }
    var counterpartConnection: DummyConnection? = nil
    let networkInterface: DummyNetworkInterface
    
    init(networkInterface: DummyNetworkInterface) {
        self.networkInterface = networkInterface
    }
    
    func connect() {}
    func close() {
        if !self.isConnected {
            println("called close on disconnected connection.")
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.internalClose()
            self.counterpartConnection?.internalClose()
        })
    }
    func internalClose() {
        if !self.isConnected {
            println("called close on disconnected connection.")
            return
        }
        
        self.isConnected = false
        self.delegate?.didClose(self, error: "Internal test close")
    }
    
    func writeData(data: NSData) {
        let type = DataReader(data).getInteger()
        if let type = PacketType(rawValue: type) {
            if type == PacketType.Unknown {
                println("Trying to send packet with invalid type.")
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.counterpartConnection?.internalReceiveData(data)
            self.delegate?.didSendData(self)
        })
    }
    func internalReceiveData(data: NSData) {
        self.delegate?.didReceiveData(self, data: data)
    }
}

class DummyOutConnection: DummyConnection {
    var inConnection: DummyInConnection
    
    init(networkInterface: DummyNetworkInterface, advertiser: DummyAdvertiser) {
        self.inConnection = DummyInConnection(networkInterface: networkInterface, advertiser: advertiser)
        
        super.init(networkInterface: networkInterface)
        
        self.counterpartConnection = self.inConnection
        self.inConnection.outConnection = self
        self.inConnection.counterpartConnection = self
    }
    override func connect() {
        self.isConnected = true
        self.inConnection.internalAnnounceOpen()
        
        self.delegate?.didConnect(self)
    }
}

class DummyInConnection: DummyConnection {
    var outConnection: DummyOutConnection!

    let advertiser: DummyAdvertiser

    init(networkInterface: DummyNetworkInterface, advertiser: DummyAdvertiser) {
        self.advertiser = advertiser
        
        super.init(networkInterface: networkInterface)
        
        self.isConnected = true
    }
    func internalAnnounceOpen() {
        self.advertiser.onConnection(self)
    }
    override func connect() {
        println("Connect called in incoming connection. Ignored.")
    }
}

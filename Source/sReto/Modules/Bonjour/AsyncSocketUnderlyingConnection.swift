//
//  AsyncSocketUnderlyingConnection.swift
//  sReto
//
//  Created by Julian Asamer on 09/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

enum AddressInformation {
    case AddressAsData(NSData, String, Int)
    case HostName(String, Int)
}

class AsyncSocketUnderlyingConnection: NSObject, UnderlyingConnection, GCDAsyncSocketDelegate {
    let HEADER_TAG = 1
    let BODY_TAG = 2
    
    let socket: GCDAsyncSocket
    let recommendedPacketSize: Int
    var isConnected: Bool {
        return self.socket.isConnected
    }
    
    //TODO: this delegate is not weak because otherwise no one holds it and it gets deinitialized
    /*weak */var delegate: UnderlyingConnectionDelegate?
    
    let addressInformation: AddressInformation?
    
    init(socket: GCDAsyncSocket, recommendedPacketSize: Int) {
        self.socket = socket
        self.recommendedPacketSize = recommendedPacketSize
        self.addressInformation = nil

        super.init()

        self.socket.delegate = self

        if self.isConnected {
            self.readHeader()
        }
    }
    
    init(dispatchQueue: dispatch_queue_t, recommendedPacketSize: Int, addressInformation: AddressInformation) {
        self.socket = GCDAsyncSocket(delegate: nil, delegateQueue: dispatchQueue, socketQueue: dispatchQueue)
        self.recommendedPacketSize = recommendedPacketSize
        self.addressInformation = addressInformation

        super.init()
        
        self.socket.delegate = self
        
        if self.isConnected {
            self.readHeader()
        }
    }
    
    func connect() {
        if (self.isConnected) {
            return
        }
        
        if let addressInformation = self.addressInformation {
            var error : NSError?
            
            switch addressInformation {
                case .AddressAsData(let data, let hostName, let port):
                    log(.Low, info: "try to connect to address data: \(data), hostName: \(hostName), port: \(port)")
                    do {
                        try socket.connectToAddress(data)
                    } catch let error1 as NSError {
                        error = error1
                    }
                    break
                case .HostName(let hostName, let port):
                    log(.Low, info: "try to connect to: \(hostName), port: \(port)")
                    do {
                        try socket.connectToHost(hostName, onPort: UInt16(port))
                    } catch let error1 as NSError {
                        error = error1
                    }
                    break
            }
            
            if let error = error {
                log(.Medium, error: "Error occured when trying to connect: \(error)")
                self.delegate?.didClose(self, error: error)
            }
            
        }
        else {
            log(.Medium, error: "Could not connect. This connection has no address information.")
        }
    }
    
    func close() {
        self.socket.disconnectAfterReadingAndWriting()
    }
    
    func socket(socket: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        log(.Low, info: "socket connected to: \(host), port: \(port)")
        self.delegate?.didConnect(self)
        self.readHeader()
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError error: NSError!) {
        log(.Medium, info: "socket disconnect, error: \(error)")
        self.delegate?.didClose(self, error: error)
    }
    
    func readHeader() {
        self.socket.readDataToLength(UInt(sizeof(Int32)), withTimeout: -1, tag: HEADER_TAG)
    }
    
    func writeData(data: NSData) {
        if (self.socket.isConnected) {
            let writer = DataWriter(length: sizeof(Int32))
            writer.add(Int32(data.length))
            
            self.socket.writeData(writer.getData(), withTimeout: -1, tag: HEADER_TAG)
            self.socket.writeData(data, withTimeout: -1, tag: BODY_TAG)
        } else {
            log(.Low, error: "attempted to write before connected.")
        }
    }
    
    func socket(socket: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        if tag == BODY_TAG {
            self.delegate?.didSendData(self)
        }
    }
    
    func socket(socket: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if (tag == HEADER_TAG) {
            let length = DataReader(data).getInteger()
            socket.readDataToLength(UInt(length), withTimeout: -1, tag: BODY_TAG)
        } else {
            self.delegate?.didReceiveData(self, data: data)
            self.readHeader()
        }
    }
}
//
//  MulticastConnection.swift
//  sReto
//
//  Created by Julian Asamer on 18/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** 
* A MulticastConnection acts like a normal underlying connection, but sends all data written to it using a set of subconnections.
* Data received from any subconnection is reported to the delegate.
*/
class MulticastConnection: UnderlyingConnection, UnderlyingConnectionDelegate {
    /** The subconnections used with this connection */
    var subconnections: [UnderlyingConnection] = []
    
    /** Stores the number of dataSent calls yet to be received. Once all are received, the delegate's didSendData can be called. */
    var dataSentCallbacksToBeReceived: Int = 0
    /** The number of data packets that have been sent in total. */
    var dataPacketsSent: Int = 0
    
    init() {}
    /** Adds a subconnection. */
    func addSubconnection(connection: UnderlyingConnection) {
        self.subconnections.append(connection)
        connection.delegate = self
    }
   
    // MARK: UnderlyingConnection protocol
    var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool { get { return subconnections.map({ $0.isConnected }).reduce(false, combine: { $0 && $1 }) } }
    var recommendedPacketSize: Int { get { return subconnections.map { $0.recommendedPacketSize }.minElement()! } }
    
    func connect() {
        for connection in self.subconnections {
            connection.connect()
        }
    }
    
    func close() {
        for connection in self.subconnections {
            connection.close()
        }
    }
    
    func writeData(data: NSData) {
        if self.dataSentCallbacksToBeReceived != 0 {
            self.dataPacketsSent++
        } else {
            self.dataSentCallbacksToBeReceived = self.subconnections.count
        }
        
        for connection in self.subconnections {
            connection.writeData(data)
        }
    }
    

    // MARK: UnderlyingConnectionDelegate protocol
    func didConnect(connection: UnderlyingConnection) {
        if self.isConnected { self.delegate?.didConnect(self) }
    }
    
    func didClose(closedConnection: UnderlyingConnection, error: AnyObject?) {
        for connection in self.subconnections {
            if connection !== closedConnection { connection.close() }
        }
        
        self.delegate?.didClose(self, error: error )
    }
    
    func didReceiveData(connection: UnderlyingConnection, data: NSData) {
        self.delegate?.didReceiveData(self, data: data)
    }
    
    func didSendData(connection: UnderlyingConnection) {
        if self.dataSentCallbacksToBeReceived == 0 {
            log(.Medium, info: "Received unexpected didSendData call.")
            return
        }
        
        self.dataSentCallbacksToBeReceived--
        
        if self.dataSentCallbacksToBeReceived == 0 {
            if self.dataPacketsSent != 0 {
                self.dataPacketsSent--
                self.dataSentCallbacksToBeReceived = self.subconnections.count
            }
        
            self.delegate?.didSendData(self)
        }
    }
}
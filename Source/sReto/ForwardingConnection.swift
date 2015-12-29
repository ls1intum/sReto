//
//  ForkingConnection.swift
//  sReto
//
//  Created by Julian Asamer on 23/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

// TODO: ignores didSendData - is this ok?
// TODO: might buffer lots of data if incoming connection is fast and outgoing connection is slow.

/**
* A ForkingConnection acts like the incomingConnection it was constructed with, but additionally forwards any data received 
* from the incoming connection to an additional outgoing connection and vice versa. Delegate methods will not be called for any events related to the outgoing connection.
*/
class ForkingConnection: NSObject, UnderlyingConnection, UnderlyingConnectionDelegate {
    /** The ForkingConnection's incoming connection. */
    let incomingConnection: UnderlyingConnection
    /** The ForkingConnection's outgoing connection */
    let outgoingConnection: UnderlyingConnection
    /** A closure to call when the connection closes. */
    let onCloseClosure: (ForkingConnection)->()
    
    /** Constructs a new ForkingConnection. */
    init(incomingConnection: UnderlyingConnection, outgoingConnection: UnderlyingConnection, onClose: (ForkingConnection)->()) {
        self.incomingConnection = incomingConnection
        self.outgoingConnection = outgoingConnection
        self.onCloseClosure = onClose
        
        super.init()
        
        self.incomingConnection.delegate = self
        self.outgoingConnection.delegate = self
    }

    func counterpartForConnection(connection: UnderlyingConnection) -> UnderlyingConnection {
        if connection === self.incomingConnection {
            return self.outgoingConnection
        }
        if connection === self.outgoingConnection {
            return self.incomingConnection
        }
        
        log(.High, error: "Trying to get counterpart to unknown connection.")
        let result: UnderlyingConnection? = nil
        return result!
    }
    
    // MARK: UnderlyingConnection protocol
    var delegate: UnderlyingConnectionDelegate? = nil
    var isConnected: Bool { get { return self.incomingConnection.isConnected && self.outgoingConnection.isConnected } }
    var recommendedPacketSize: Int { get { return self.incomingConnection.recommendedPacketSize } }
    
    func connect() {
        log(.High, error: "Connect called on Forwarding connection. Should already be connected.")
    }
    func close() {
        self.incomingConnection.close()
        self.outgoingConnection.close()
    }
    func writeData(data: NSData) {
        self.incomingConnection.writeData(data)
    }
    
    // MARK: UnderlyingConnectionDelegate protocol
    
    func didConnect(connection: UnderlyingConnection) {
        log(.High, error: "Forwarding connection received a didConnect call. This should not happen as the underlying connections should be established already.")
    }
    func didClose(connection: UnderlyingConnection, error: AnyObject?) {
        log(.Low, info: "An underlying connection closed. Closing other connection.")
        self.incomingConnection.delegate = nil
        self.outgoingConnection.delegate = nil
        
        self.counterpartForConnection(connection).close()
        
        self.delegate?.didClose(self, error: error)
        self.onCloseClosure(self)
    }
    func didReceiveData(connection: UnderlyingConnection, data: NSData) {
        if connection === incomingConnection {
            self.delegate?.didReceiveData(self, data: data)
        }
        
        self.counterpartForConnection(connection).writeData(data)
    }
    func didSendData(connection: UnderlyingConnection) {
        if connection === self.incomingConnection {
            self.delegate?.didSendData(self)
        }
    }
    

}
//
//  UnderlyingConnection.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/** 
* The UnderlyingConnectionDelegate allows the UnderlyingConnection to inform its delegate about various events.
*/
public protocol UnderlyingConnectionDelegate : class {
    /** Called when the connection connected successfully.*/
    func didConnect(connection: UnderlyingConnection)
    /** Called when the connection closes. Has an optional error parameter to indicate issues. (Used to report problems to the user). */
    func didClose(connection: UnderlyingConnection, error: AnyObject?)
    /** Called when data was received. */
    func didReceiveData(connection: UnderlyingConnection, data: NSData)
    /** 
    * Called for each writeData call, when it is complete.
    * Note: The current implementation of Reto does not work when this method is called directly from writeData. If you wish to call it immediately, use dispatch_async to call it.
    */
    func didSendData(connection: UnderlyingConnection)
}

/**
* An UnderlyingConnection is a Connection with the minimal necessary functionality that allows the implementation of Reto connections on top of it.
* It is called UnderlyingConnection to differentiate it from Reto's high-level Connection class, which offers many additional features.
* Reto's users don't interact with this class directly.
*/
public protocol UnderlyingConnection : class {
    /** The connection's delegate. */
    /*weak */var delegate : UnderlyingConnectionDelegate? { get set }
    /** Whether this connection is currently connected. */
    var isConnected : Bool { get }
    /** Reto sends packets which may vary in size. This property may return an ideal packet size that should be used if possible. */
    var recommendedPacketSize : Int { get }
    
    /** Connects the connection. */
    func connect()
    /** Closes the connection. */
    func close()
    /** Sends data using the connection. */
    func writeData(data : NSData)
}

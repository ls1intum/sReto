//
//  RemoteP2PConnection.swift
//  sReto
//
//  Created by Julian Asamer on 07/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation
import SocketRocket

class RemoteP2PConnection: NSObject, UnderlyingConnection, SRWebSocketDelegate {
    weak var delegate: UnderlyingConnectionDelegate?
    var isConnected: Bool = false
    var receivedConnectionConfirmation = false
    var recommendedPacketSize: Int = 2048
    var serverUrl: NSURL?
    let dispatchQueue: dispatch_queue_t
    var selfRetain: RemoteP2PConnection?
    
    var socket: SRWebSocket?
    
    override var description: String {
        return "RemoteP2PConnection: {url: \(self.serverUrl), isConnected: \(self.isConnected), webSocket: \(self.socket)}"
    }
    
    init(serverUrl: NSURL, dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
        
        super.init()
        
        self.serverUrl = serverUrl
        self.selfRetain = self
    }
    init(socket: SRWebSocket, dispatchQueue: dispatch_queue_t) {
        self.socket = socket
        self.dispatchQueue = dispatchQueue
        self.socket?.setDelegateDispatchQueue(dispatchQueue)
        self.isConnected = true
        self.receivedConnectionConfirmation = true
        super.init()
        self.selfRetain = self
        socket.delegate = self
    }
    
    func connect() {
        if let url = self.serverUrl {
            self.socket = SRWebSocket(URL: url)
            self.socket?.setDelegateDispatchQueue(self.dispatchQueue)
            self.socket?.delegate = self
            self.socket?.open()
        }
    }
    func close() {
        self.socket?.close()
        self.socket = nil
    }
    func writeData(data: NSData) {
        if !isConnected {
            log(.High, error: "Attempted to write data before connection connected.")
            return
        }

        self.socket?.send(data)
        dispatch_async(self.dispatchQueue, { () -> Void in
            self.delegate?.didSendData(self)
            return
        })
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {}
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        log(.Low, info: "closed web socket. Code: \(code), reason: \(reason), wasClean: \(wasClean)")
    
        self.delegate?.didClose(self, error: wasClean ? nil : "Code: \(code), reason: \(reason), wasClean: \(wasClean)")
    }
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        log(.Low, info: "closed with error: \(error)")
        
        self.delegate?.didClose(self, error: error)
    }
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        if let data = message as? NSData {
            if !receivedConnectionConfirmation {
                let reader = DataReader(data)
                if !reader.checkRemaining(4) || reader.getInteger() != 1 {
                    log(.High, error: "Expected confirmation, other data received.")
                    self.close()
                    return
                } else {
                    self.receivedConnectionConfirmation = true
                    self.isConnected = true
                    self.delegate?.didConnect(self)
                }
            } else {
                self.delegate?.didReceiveData(self, data: data)
            }
        }
    }
}

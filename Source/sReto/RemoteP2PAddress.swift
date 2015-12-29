//
//  RemoteP2PAddress.swift
//  sReto
//
//  Created by Julian Asamer on 07/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class RemoteP2PAddress: NSObject, Address {
    let serverUrl: NSURL
    let cost = 50
    let hostName: String
    
    override var description: String {
        return "RemoteP2PAddress: {url: \(self.serverUrl)}"
    }
    
    let dispatchQueue: dispatch_queue_t

    init(serverUrl: NSURL, dispatchQueue: dispatch_queue_t) {
        self.hostName = serverUrl.absoluteString
        self.serverUrl = serverUrl
        self.dispatchQueue = dispatchQueue
    }
    
    func createConnection() -> UnderlyingConnection {
        return RemoteP2PConnection(serverUrl: serverUrl, dispatchQueue: dispatchQueue)
    }
}
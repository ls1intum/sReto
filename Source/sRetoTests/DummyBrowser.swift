//
//  DummyBrowser.swift
//  sReto
//
//  Created by Julian Asamer on 17/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class DummyBrowser: NSObject, Browser {
    let networkInterface: DummyNetworkInterface
    var browserDelegate: BrowserDelegate?
    var isBrowsing: Bool = false
    var addresses: [UUID: DummyAddress] = [:]
    
    init(networkInterface: DummyNetworkInterface) {
        self.networkInterface = networkInterface
    }
    
    func startBrowsing() {
        self.networkInterface.register(self)
        self.isBrowsing = true
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
             if let delegate = self.browserDelegate { delegate.didStartBrowsing(self) }
        })
        //DispatchQueue.main().dispatch({ if let delegate = self.browserDelegate { delegate.didStartBrowsing(self) } })
    }
    func stopBrowsing() {
        self.networkInterface.unregister(self)
        self.isBrowsing = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let delegate = self.browserDelegate { delegate.didStopBrowsing(self) }
        })
        //DispatchQueue.main().dispatch({ if let delegate = self.browserDelegate { delegate.didStopBrowsing(self) } })
    }
    func onAddPeer(identifier: UUID, address: DummyAddress) {
        addresses[identifier] = address
        self.browserDelegate?.didDiscoverAddress(self, address: address, identifier: identifier)
    }
    func onRemovePeer(identifier: UUID) {
        self.browserDelegate?.didRemoveAddress(self, address: addresses[identifier]!, identifier: identifier)
        addresses[identifier] = nil
    }
}
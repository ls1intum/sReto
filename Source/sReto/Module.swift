//
//  Module.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

/**
* A Reto module encapsulates a networking technology that can be passed to a LocalPeer.
* It consists of an Advertiser that advertises peers (i.e. makes the local peer discoverable), and a Browser that finds other peers (i.e. discovers other peers).
*/
public protocol Module: class {
    /** The Module's advertiser */
    var advertiser: Advertiser { get }
    /** The Module's browser */
    var browser: Browser { get }
    /** 
    * If the Module requires a disptach queue for asynchronous operations, the LocalPeer will call setDispatch queue with the networking dispatch queue.
    * It is expected that delegate methods will be called on this dispatch queue.
    */
    func setDispatchQueue(dispatchQueue: dispatch_queue_t)
}
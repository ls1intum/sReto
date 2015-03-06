//
//  Browser.swift
//  sReto
//
//  Created by Julian Asamer on 12/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

/**
* The BrowserDelegate protocol allows an implementation of the Browser protocol to inform it's delegate about various events.
*/
@objc(RTBrowserDelegate) public protocol BrowserDelegate {
    /** Called when the Browser started to browse. */
    func didStartBrowsing(browser: Browser)
    /** Called when the Browser stopped to browse. */
    func didStopBrowsing(browser: Browser)
    /** Called when the Browser discovered an address. */
    func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID)
    /** Called when the Browser lost an address, i.e. when that address becomes invalid for any reason. */
    func didRemoveAddress(browser: Browser, address: Address, identifier: UUID)
}

/** A Browser attempts to discover other peers; it is the counterpart to the same module's advertiser. */
@objc(RTBrowser) public protocol Browser {
    /** Whether the Browser is currently active. */
    var isBrowsing: Bool { get }
    /** The Browser's delegate */
    var browserDelegate: BrowserDelegate? { get set }

    /** Starts browsing for other peers. */
    func startBrowsing()
    /** Stops browsing for other peers. */
    func stopBrowsing()
}
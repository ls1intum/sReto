//
//  DummyModuleTest.swift
//  sReto
//
//  Created by Julian Asamer on 18/09/14.
//  Copyright (c) 2014 - 2016 Chair for Applied Software Engineering
//
//  Licensed under the MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness
//  for a particular purpose and noninfringement. in no event shall the authors or copyright holders be liable for any claim, damages or other liability, 
//  whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
//

import UIKit
import XCTest

class ModuleTest: XCTestCase {
    
    func testDummyModule() {
        let testInterface = DummyNetworkInterface(interfaceName: "test", cost: 1)
        let module1 = DummyModule(networkInterface: testInterface)
        let module2 = DummyModule(networkInterface: testInterface)
        self.testWithModules(module1, module1Identifier: randomUUID(), module2: module2)
    }
    
    // Tests the WlanModule. Wlan needs to be active.
    func testWlanModule() {
        let module1 = WlanModule(type: "sRetoIntegrationTest", dispatchQueue: dispatch_get_main_queue())
        let module2 = WlanModule(type: "sRetoIntegrationTest", dispatchQueue: dispatch_get_main_queue())
        self.testWithModules(module1, module1Identifier: randomUUID(), module2: module2)
    }
    
    // Tests the BluetoothModule. Bluetooth needs to be active.
    func testBluetoothModule() {
        let module1 = BluetoothModule(type: "sRetoIntegrationTest", dispatchQueue: dispatch_get_main_queue())
        let module2 = BluetoothModule(type: "sRetoIntegrationTest", dispatchQueue: dispatch_get_main_queue())
        self.testWithModules(module1, module1Identifier: randomUUID(), module2: module2)
    }
    
    // For obvious reasons, this test can only succeed when the RemoteP2P server instance is freshly deployed locally (ie. it may not discover any other peers).
    func testRemoteModule() {
        let module1 = RemoteP2PModule(baseUrl: NSURL(string: "ws://localhost:8080")!, dispatchQueue: dispatch_get_main_queue())
        let module2 = RemoteP2PModule(baseUrl: NSURL(string: "ws://localhost:8080")!, dispatchQueue: dispatch_get_main_queue())
        self.testWithModules(module1, module1Identifier: randomUUID(), module2: module2)
    }
    
    var refs: [AnyObject] = []
    
    func testWithModules(module1: Module, module1Identifier: UUID, module2: Module) {
        let startedAdvertisingExpectation = self.expectationWithDescription("advertising started")
        let startedBrowsingExpectation = self.expectationWithDescription("browsing started")
        let discoveredAddressExpectation = self.expectationWithDescription("address discovered")
        let connectionHandledExpectation = self.expectationWithDescription("connection handled")
        let connectionEstablishedExpectation = self.expectationWithDescription("connection established")
        let dataSentExpectation = self.expectationWithDescription("data sent")
        let dataReceivedExpectation = self.expectationWithDescription("data received")
        let connectionClosedExpectation = self.expectationWithDescription("connection closed")
        
        class OutConnectionDelegate: UnderlyingConnectionDelegate {
            let connectionEstablishedExpectation: XCTestExpectation
            let connectionClosedExpectation: XCTestExpectation
            let dataSentExpectation: XCTestExpectation
            
            init(connectionEstablishedExpectation: XCTestExpectation, connectionClosedExpectation: XCTestExpectation, dataSentExpectation: XCTestExpectation) {
                self.connectionEstablishedExpectation = connectionEstablishedExpectation
                self.connectionClosedExpectation = connectionClosedExpectation
                self.dataSentExpectation = dataSentExpectation
            }
            
            func didConnect(connection: UnderlyingConnection) {
                connectionEstablishedExpectation.fulfill()
                
                connection.writeData(TestData.generate(100))
            }
            func didClose(connection: UnderlyingConnection, error: AnyObject?) {
                print("error: \(error)")
                connectionClosedExpectation.fulfill()
            }
            func didReceiveData(connection: UnderlyingConnection, data: NSData) {}
            func didSendData(connection: UnderlyingConnection) {
                dataSentExpectation.fulfill()
            }
        }
        
        class InConnectionDelegate: UnderlyingConnectionDelegate {
            let dataReceivedExpectation: XCTestExpectation
            
            init(dataReceivedExpectation: XCTestExpectation) {
                self.dataReceivedExpectation = dataReceivedExpectation
            }
            
            func didConnect(connection: UnderlyingConnection) {}
            func didClose(connection: UnderlyingConnection, error: AnyObject?) {}
            func didReceiveData(connection: UnderlyingConnection, data: NSData) {
                XCTAssertTrue(TestData.verify(data, expectedLength: 100), "Incorrect data received.")
                dataReceivedExpectation.fulfill()
                
                connection.close()
            }
            func didSendData(connection: UnderlyingConnection) {}
        }

        class Module1Delegate: AdvertiserDelegate, BrowserDelegate {
            let connectionEstablishedExpectation: XCTestExpectation
            let startedAdvertisingExpectation: XCTestExpectation
            let startedBrowsingExpectation: XCTestExpectation
            let discoveredAddressExpectation: XCTestExpectation
            let outConnectionDelegate: OutConnectionDelegate
            let localIdentifier: UUID
            var connection: UnderlyingConnection? = nil
            
            init(connectionEstablishedExpectation: XCTestExpectation, startedAdvertisingExpectation: XCTestExpectation, startedBrowsingExpectation: XCTestExpectation, discoveredAddressExpectation: XCTestExpectation, outConnectionDelegate: OutConnectionDelegate, localIdentifier: UUID) {
                self.connectionEstablishedExpectation = connectionEstablishedExpectation
                self.startedAdvertisingExpectation = startedAdvertisingExpectation
                self.startedBrowsingExpectation = startedBrowsingExpectation
                self.discoveredAddressExpectation = discoveredAddressExpectation
                self.outConnectionDelegate = outConnectionDelegate
                self.localIdentifier = localIdentifier
            }
            
            func didStartAdvertising(advertiser: Advertiser) {
                self.startedAdvertisingExpectation.fulfill()
            }
            func didStopAdvertising(advertiser: Advertiser) { }
            func handleConnection(advertiser: Advertiser, connection: UnderlyingConnection) { }
            
            func didStartBrowsing(browser: Browser) {
                self.startedBrowsingExpectation.fulfill()
            }
            func didStopBrowsing(browser: Browser) { }
            func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID) {
                if localIdentifier == identifier { return }
                
                self.discoveredAddressExpectation.fulfill()
                
                let connection = address.createConnection()
                connection.delegate = outConnectionDelegate
                connection.connect()
                self.connection = connection
            }
            func didRemoveAddress(browser: Browser, address: Address, identifier: UUID) { }
        }
        
        class Module2Delegate: AdvertiserDelegate, BrowserDelegate {
            let connectionHandledExpectation: XCTestExpectation
            let inConnectionDelegate: InConnectionDelegate
            var connection: UnderlyingConnection? = nil

            init(connectionHandledExpectation: XCTestExpectation, inConnectionDelegate: InConnectionDelegate) {
                self.connectionHandledExpectation = connectionHandledExpectation
                self.inConnectionDelegate = inConnectionDelegate
            }
            
            func didStartAdvertising(advertiser: Advertiser) {}
            func didStopAdvertising(advertiser: Advertiser) { }
            func handleConnection(advertiser: Advertiser, connection: UnderlyingConnection) {
                connectionHandledExpectation.fulfill()
                self.connection = connection
                connection.delegate = inConnectionDelegate
            }
            
            func didStartBrowsing(browser: Browser) {}
            func didStopBrowsing(browser: Browser) { }
            func didDiscoverAddress(browser: Browser, address: Address, identifier: UUID) {}
            func didRemoveAddress(browser: Browser, address: Address, identifier: UUID) {}
        }
        
        let module1Delegate = Module1Delegate(connectionEstablishedExpectation: connectionEstablishedExpectation, startedAdvertisingExpectation: startedAdvertisingExpectation, startedBrowsingExpectation: startedBrowsingExpectation, discoveredAddressExpectation: discoveredAddressExpectation, outConnectionDelegate: OutConnectionDelegate(connectionEstablishedExpectation: connectionEstablishedExpectation, connectionClosedExpectation: connectionClosedExpectation, dataSentExpectation: dataSentExpectation), localIdentifier: module1Identifier)
        let module2Delegate = Module2Delegate(connectionHandledExpectation: connectionHandledExpectation, inConnectionDelegate: InConnectionDelegate(dataReceivedExpectation: dataReceivedExpectation))
        
        refs.append(module1)
        refs.append(module2)
        refs.append(module1Delegate)
        refs.append(module2Delegate)
        
        module1.advertiser.advertiserDelegate = module1Delegate
        module1.browser.browserDelegate = module1Delegate
        module2.advertiser.advertiserDelegate = module2Delegate
        module2.browser.browserDelegate = module2Delegate
        
        module1.advertiser.startAdvertising(module1Identifier)
        module1.browser.startBrowsing()
        module2.advertiser.startAdvertising(randomUUID())
        module2.browser.startBrowsing()
        
        self.waitForExpectationsWithTimeout(20, handler: {
            error in
            print("Finished waiting, error: \(error)")
        })
    }
}

//
//  UUIDTests.swift
//  sReto
//
//  Created by Julian Asamer on 20/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import UIKit
import XCTest

class UUIDTests: XCTestCase {
    func testUUIDStringConversion() {
        let id = randomUUID()
        let string = id.UUIDString
        let reconstructedId = UUIDfromString(string)
        
        if let reconstructedId = reconstructedId {
            XCTAssert(id == reconstructedId, "Not equal after reconstruction")
            XCTAssert(id.hashValue == reconstructedId.hashValue, "Hash values not equal")
        } else {
            XCTAssert(false, "Could not reconstruct uuid.")
        }
    }
}

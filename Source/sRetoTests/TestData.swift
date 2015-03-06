//
//  TestData.swift
//  sReto
//
//  Created by Julian Asamer on 18/09/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

class TestData {
    class func generate(length: Int) -> NSData {
        let data = DataWriter(length: length)
        
        for i in 0..<length { data.add(UInt8(i%127)) }
        
        return data.getData()
    }
    
    class func verify(data: NSData, expectedLength: Int) -> Bool {
        let reader = DataReader(data)
        
        if data.length != expectedLength {
            println("Verifying test data failed: Incorrect length.")
            return false
        }
        
        for i in 0..<data.length {
            if reader.getByte() != UInt8(i % 127) {
                println("Data incorrect.")
                return false
            }
        }
        
        return true
    }
}
//
//  OutTransfer.swift
//  sReto
//
//  Created by Julian Asamer on 26/07/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

/**
* An OutTransfer represents a data transfer from the local peer to a remote peer. You can obtain one by calling the connection's send method.
*/
@objc(RTOutTransfer) public class OutTransfer: Transfer {
    public let dataProvider: (range: NSRange) -> NSData
    
    init(manager: TransferManager, dataLength: Int, dataProvider: (range: NSRange) -> NSData, identifier: UUID) {
        self.dataProvider = dataProvider
        
        super.init(manager: manager, length: dataLength, identifier: identifier)
    }
    
    func nextPacket(length: Int) -> DataPacket {
        let dataLength = min(self.length - self.progress, length - 4)
        let packet = DataPacket(data: self.dataProvider(range: NSMakeRange(self.progress, dataLength)))
        self.progress += dataLength
        
        return packet
    }
    
    public override func cancel() { self.manager?.cancel(self) }
}

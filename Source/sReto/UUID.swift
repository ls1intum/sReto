//
//  UUID.swift
//  sReto
//
//  Created by Julian Asamer on 15/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

import Foundation

extension NSUUID {
    convenience init(uuid: UUID) {
        var u = uuid.uuidt
        self.init(UUIDBytes: &u.0)
    }
}

let UUID_T_ZERO: uuid_t = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
let UUID_ZERO: UUID = fromUUID_T(UUID_T_ZERO)

/** 
* This class represents unique universal identifiers, aka UUIDs.
* This class' primary purpose is to make the underlying byte array easier to access than the NSUUID class.
*/
public struct UUID: Comparable, Hashable, CustomStringConvertible {
    /** Stores the UUID as a 16 byte array */
    let uuid: [UInt8]
    public var hashValue: Int {
        return uuid.map { $0.hashValue }.enumerate().reduce(0,
            combine: {
                let (index, hash) = $1
                return $0 ^ (hash << index * 2)
            }
        )
    }
    /** Returns the UUID as a uuid_t as defined by the Foundation framework */
    public var uuidt: uuid_t {
        return (
            uuid[ 0], uuid[ 1], uuid[ 2], uuid[ 3],
            uuid[ 4], uuid[ 5], uuid[ 6], uuid[ 7],
            uuid[ 8], uuid[ 9], uuid[10], uuid[11],
            uuid[12], uuid[13], uuid[14], uuid[15]
        )
    }
    
    /** Returns the string representation of this UUID */
    public var UUIDString: String {
        return NSUUID(uuid: self).UUIDString
    }
    
    public var description: String {
        return self.UUIDString
    }
    
    /** Constructs an UUID from a byte array. */
    public init(uuid: [UInt8]) {
        self.uuid = uuid
    }
}

/** Constructs a random UUID. */
public func randomUUID() -> UUID {
    return fromNSUUID(NSUUID())
}

/** Converts an NSUUID to a UUID. */
public func fromNSUUID(nsuuid: NSUUID) -> UUID {
    var uuid: uuid_t = UUID_T_ZERO
    withUnsafeMutablePointer(&uuid.0, { pointer in nsuuid.getUUIDBytes(pointer)})
    return fromUUID_T(uuid)
}

/** Converts an uuid_t to a UUID. */
public func fromUUID_T(uuid: uuid_t) -> UUID {
    return UUID(
        uuid: [
            uuid.0, uuid.1, uuid.2, uuid.3,
            uuid.4, uuid.5, uuid.6, uuid.7,
            uuid.8, uuid.9, uuid.10, uuid.11,
            uuid.12, uuid.13, uuid.14, uuid.15
        ]
    )
}

/** Constructs an UUID from its string representation. */
public func UUIDfromString(string: String) -> UUID? {
    if let uuid = NSUUID(UUIDString: string) {
        return fromNSUUID(uuid)
    } else {
        return nil
    }
}

public func == (id1: UUID, id2: UUID) -> Bool {
    return id1.uuid == id2.uuid
}
/** Interprets the UUIDs as 16 byte integers to compare them. */
public func < (id1: UUID, id2: UUID) -> Bool {
    return id1.uuid < id2.uuid
}

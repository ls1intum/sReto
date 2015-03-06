//
//  sRetoMac.h
//  sRetoMac
//
//  Created by Julian Asamer on 04/08/14.
//  Copyright (c) 2014 LS1 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for sRetoMac.
FOUNDATION_EXPORT double sRetoVersionNumber;

//! Project version string for sRetoMac.
FOUNDATION_EXPORT const unsigned char sRetoVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <sRetoMac/PublicHeader.h>

// Local Connectivity
#import "GCDAsyncSocket.h"

// Bluetooth advertisment via Bonjour
#import "DNSSDBrowser.h"
#import "DNSSDRegistration.h"
#import "DNSSDService.h"

// Remote P2P
#import "base64.h"
#import "NSData+SRB64Additions.h"
#import "SRWebSocket.h"

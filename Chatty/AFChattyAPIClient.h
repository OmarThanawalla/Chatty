//
//  AFChattyAPIClient.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface AFChattyAPIClient : AFHTTPClient

+ (AFChattyAPIClient *)sharedClient;

@end

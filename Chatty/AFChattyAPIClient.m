//
//  AFChattyAPIClient.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFChattyAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFChattyAPIBaseURLString = @"http://localhost:3000";


@implementation AFChattyAPIClient

+ (AFChattyAPIClient *)sharedClient {
    //create a shared client
    static AFChattyAPIClient *_sharedClient = nil;
    //dont know what the next two lines mean
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //the shared client initialized with base url, calls the below method
        _sharedClient = [[AFChattyAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFChattyAPIBaseURLString]];
    });
    
    //returns the shared client
    return _sharedClient;
    
    
}

//he overrides the initialzer of this class in order to add AFJSONRequestOperation and setting some default headers
- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}


@end

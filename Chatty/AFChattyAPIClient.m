//
//  AFChattyAPIClient.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFChattyAPIClient.h"
#import "AFJSONRequestOperation.h"
#import <CommonCrypto/CommonDigest.h>

//static NSString * const kAFChattyAPIBaseURLString = @"http://localhost:3000";

static NSString * const kAFChattyAPIBaseURLString = @"http://stark-night-7250.herokuapp.com";


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

//implement hashing functionality for password
+(NSString*) digest:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}


@end

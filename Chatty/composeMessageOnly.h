//
//  composeMessageOnly.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class autoCompleteEngine;

@interface composeMessageOnly : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *messageBody;
@property (strong, nonatomic) NSString *conversationID;
@property (strong, nonatomic) NSString *preAddressing;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *characterCount;
//This will hold our viewcontroller to display the autocompleted choices
@property (nonatomic, strong) autoCompleteEngine * autoCompleteObject;
@property (nonatomic, assign) BOOL viewOn;

-(IBAction)cancel;
-(IBAction)submit;


@end

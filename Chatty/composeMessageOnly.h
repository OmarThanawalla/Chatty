//
//  composeMessageOnly.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface composeMessageOnly : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *messageBody;
@property (strong, nonatomic) NSString *conversationID;

-(IBAction)cancel;
-(IBAction)submit;


@end

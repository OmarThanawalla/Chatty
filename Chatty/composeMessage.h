//
//  composeMessage.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface composeMessage : UIViewController

/*
@protocol composeMessageDelegate <NSObject>
@required
//something goes in here
-(void)set
@end
 */

@property (nonatomic, retain) IBOutlet UITextView *myTextView;
@property (nonatomic, retain) IBOutlet UILabel *dialogue;
-(IBAction)cancelButton;
-(IBAction)sendButton;

@end

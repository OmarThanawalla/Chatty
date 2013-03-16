//
//  ResetPassword.m
//  Chatty
//
//  Created by Omar Thanawalla on 3/16/13.
//
//

#import "ResetPassword.h"

@interface ResetPassword ()

@end

@implementation ResetPassword

@synthesize currentPassword,updatePassword,updatePassword2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)submit
{
    NSLog(@"You hit the submit button");
}
-(IBAction)dismiss
{
    NSLog(@"You hit the dismiss button");
}

@end

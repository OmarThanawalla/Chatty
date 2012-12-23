//
//  editProfileModal.m
//  Chatty
//
//  Created by Omar Thanawalla on 12/22/12.
//
//

#import "editProfileModal.h"

@interface editProfileModal ()

@end

@implementation editProfileModal
@synthesize firstName, lastName,Bio;
@synthesize profilePic;

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

-(IBAction)cancel
{
    NSLog(@"You hit the cancel button");
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)save
{
    NSLog(@"You hit the save button");
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)editPicture
{
    NSLog(@"You hit the editPicture button");
    
    
    
    
    
}

@end

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
@synthesize imagePicker;

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
    //initialize imagePicker, imagePicker is a navigationController, which is a viewController as well
    imagePicker = [[UIImagePickerController alloc]init];
    
    //set the delegate
    imagePicker.delegate = self;
    
    //set the sourceType to camera or photoLibrary
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //present imagePicker as modalView
    [self presentModalViewController:imagePicker animated:YES];
    
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //image property is a UIImage
    profilePic.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

//
//  PendingRequestCell.h
//  Chatty
//
//  Created by Omar Thanawalla on 8/20/12.
//
//

#import <UIKit/UIKit.h>

@interface PendingRequestCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *fullName;
@property (nonatomic, strong) IBOutlet UILabel *bio;
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (strong, nonatomic) NSString *userID;
@property (nonatomic, strong) IBOutlet UIButton * cnfmButton;


-(IBAction) confirmButton;

@end

//
//  ProfileViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/10/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "ProfileViewController.h"
#import "Constants.h"
#import <PFFile.h>

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	PFFile *pictureFile = self.photo[kSMTPhotoPictureKey];
	[pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		self.profilePictureImageView.image = [UIImage imageWithData:data];
	}];

	PFUser *user = self.photo[kSMTPhotoUserKey];
	self.locationLabel.text = user[kSMTUserProfileKey][kSMTUserProfileLocationKey];
	self.ageLabel.text = [NSString stringWithFormat:@"%@",user[kSMTUserProfileKey][kSMTUserProfileAgeKey]];
	self.statusLabel.text = user[kSMTUserProfileKey][kSMTUserProfileRelationshipStatusKey];
	self.tagLineLabel.text = user[kSMTUserTagLineKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

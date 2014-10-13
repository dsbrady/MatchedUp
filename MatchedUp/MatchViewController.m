//
//  MatchViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/12/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "MatchViewController.h"
#import "Constants.h"
#import <PFFile.h>
#import <PFQuery.h>


@interface MatchViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (strong, nonatomic) IBOutlet UIButton *viewChatsButton;
@property (strong, nonatomic) IBOutlet UIButton *keepSearchingButton;


@end

@implementation MatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	PFQuery *query = [PFQuery queryWithClassName:kSMTPhotoClassKey];
	[query whereKey:kSMTPhotoUserKey equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error && [objects count] > 0)
		{
			PFObject *photo = objects[0];
			PFFile *pictureFile = photo[kSMTPhotoPictureKey];
			[pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				if (!error)
				{
					self.currentUserImageView.image = [UIImage imageWithData:data];
					self.matchedUserImageView.image = self.matchedUserImage;
				}
			}];
		}
	}];
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

#pragma mark - IBActions

- (IBAction)viewChatsButtonPressed:(UIButton *)sender
{
	[self.delegate presentMatchesViewController];
}

- (IBAction)keepSearchingButtonPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end

//
//  HomeViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/9/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "HomeViewController.h"
#import <PFQuery.h>

@interface HomeViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) int currentPhotoIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// We don't want users to be able to push the buttons before the pictures download
	self.likeButton.enabled = NO;
	self.dislikeButton.enabled = NO;
	self.infoButton.enabled = NO;

	self.currentPhotoIndex = 0;

	// Query to get the other users
	PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
	[query includeKey:@"user"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.photos = objects;
		}
		else
		{
			NSLog(@"Error getting users: %@",error);
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

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
}
- (IBAction)dislikebuttonPressed:(UIButton *)sender {
}
- (IBAction)infoButtonPressed:(UIButton *)sender {
}





@end

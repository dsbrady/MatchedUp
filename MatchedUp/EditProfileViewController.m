//
//  EditProfileViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/10/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>
#import <PFFile.h>
#import <PFQuery.h>



@interface EditProfileViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;


@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.tagLineTextView.delegate = self;
	self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];

	PFQuery *query = [PFQuery queryWithClassName:kSMTPhotoClassKey];
	[query whereKey:kSMTPhotoUserKey equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if ([objects count] > 0)
		{
			PFObject *photo = objects[0];
			PFFile *pictureFile = photo[kSMTPhotoPictureKey];
			[pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				self.profilePictureImageView.image = [UIImage imageWithData:data];
			}];
		}
	}];

	self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kSMTUserTagLineKey];
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

#pragma mark - <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[self.tagLineTextView resignFirstResponder];
		[[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kSMTUserTagLineKey];
		[[PFUser currentUser] saveInBackground];
		[self.navigationController popViewControllerAnimated:YES];
		return NO;
	}
	else
	{
		return YES;
	}
}

@end

//
//  SettingsViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/9/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>
#import <PFFile.h>
#import <PFQuery.h>

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *menSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singlesSwitch;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kSMTAgeMaxKey];
	self.menSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTMenEnabledKey];
	self.womenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTWomenEnabledKey];
	self.singlesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTSinglesEnabledKey];

	[self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.menSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.singlesSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

	self.ageLabel.text = [NSString stringWithFormat:@"%i",(int)self.ageSlider.value];
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

- (IBAction)logoutButtonPressed:(UIButton *)sender
{
	[PFUser logOut];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editProfileButtonPressed:(UIButton *)sender {
}

#pragma mark - Helper functions

-(void)valueChanged:(id)sender
{
	if (sender == self.ageSlider)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSlider.value forKey:kSMTAgeMaxKey];
		self.ageLabel.text = [NSString stringWithFormat:@"%i",(int)self.ageSlider.value];
	}
	else if (sender == self.menSwitch)
	{
		[[NSUserDefaults standardUserDefaults] setBool:self.menSwitch.on forKey:kSMTMenEnabledKey];
	}
	else if (sender == self.womenSwitch)
	{
		[[NSUserDefaults standardUserDefaults] setBool:self.womenSwitch.on forKey:kSMTWomenEnabledKey];
	}
	else if (sender == self.singlesSwitch)
	{
		[[NSUserDefaults standardUserDefaults] setBool:self.singlesSwitch.on forKey:kSMTSinglesEnabledKey];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

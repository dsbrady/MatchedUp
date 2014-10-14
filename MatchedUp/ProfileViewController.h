//
//  ProfileViewController.h
//  MatchedUp
//
//  Created by Scott Brady on 10/10/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@protocol ProfileViewControllerDelegate <NSObject>

-(void)didPressLike;

-(void)didPressDislike;

@end

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;

@property (weak, nonatomic) id <ProfileViewControllerDelegate> delegate;

@end

//
//  MatchViewController.h
//  MatchedUp
//
//  Created by Scott Brady on 10/12/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;

@property (weak) id <MatchViewControllerDelegate> delegate;

@end

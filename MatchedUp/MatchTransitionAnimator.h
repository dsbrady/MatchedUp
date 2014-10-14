//
//  MatchTransitionAnimator.h
//  MatchedUp
//
//  Created by Scott Brady on 10/13/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MatchTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end

//
//  ChatViewController.h
//  MatchedUp
//
//  Created by Scott Brady on 10/12/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <PFQuery.h>

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatroom;

@end

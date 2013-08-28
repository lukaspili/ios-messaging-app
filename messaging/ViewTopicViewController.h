//
//  ViewTopicViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"

@interface ViewTopicViewController : UITableViewController

@property (strong, nonatomic) Conversation *conversation;

@end

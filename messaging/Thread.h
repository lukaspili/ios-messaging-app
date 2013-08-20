//
//  Thread.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Thread : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) NSInteger itemsCount;
@property (assign, nonatomic) NSInteger remoteUserId;

@end

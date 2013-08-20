//
//  WebClient.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "User.h"
#import "Post.h"
#import "Comment.h"
#import "Topic.h"

@interface WebClient : AFHTTPClient

+ (WebClient *)sharedInstance;

- (void)loginWithName:(NSString *)name callbackBlock:(void (^)(BOOL success, User *user))callbackBlock;

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock;
- (void)createPost:(Post *)post callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getCommentsForPost:(Post *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock;
- (void)createComment:(Comment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock;

- (void)getTopicsForCurrentUserWithCallbackBlock:(void (^)(BOOL success, NSArray *topics))callbackBlock;
- (void)createTopic:(Topic *)topic callbackBlock:(void (^)(BOOL success))callbackBlock;

@end

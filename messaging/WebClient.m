//
//  WebClient.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "WebClient.h"

@implementation WebClient

static WebClient *instance = nil;

+ (WebClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://some.url"]];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self) {
        return nil;
    }
    
    [self setDefaultHeader:@"Accept-Charset" value:@"utf-8"];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    return self;
}

- (void)loginWithName:(NSString *)name callbackBlock:(void (^)(BOOL success, User *user))callbackBlock
{
    if(ENV_FAKE_API) {
        User *user = [[User alloc] init];
        user.name = @"Lukas";
        user.remoteId = 1;
        
        callbackBlock(YES, user);
        return;
    }
    
    [self postPath:@"login" parameters:@{@"name": name} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    if(ENV_FAKE_API) {
        User *user = [[User alloc] init];
        user.name = @"Tade";
        
        Post *post1 = [[Post alloc] init];
        post1.content = @"Post 1";
        post1.date = [NSDate date];
        post1.socialContent.likes = 10;
        post1.socialContent.hates = 5;
        post1.user = user;
        
        Post *post2 = [[Post alloc] init];
        post2.content = @"Post 2";
        post2.date = [NSDate date];
        post2.socialContent.likes = 10;
        post2.socialContent.hates = 5;
        post2.user = user;
        
        Post *post3 = [[Post alloc] init];
        post3.content = @"Post 3";
        post3.date = [NSDate date];
        post3.socialContent.likes = 10;
        post3.socialContent.hates = 5;
        post3.user = user;
        
        NSArray *posts = [NSArray arrayWithObjects:post1, post2, post3, nil];
        callbackBlock(YES, posts);
        return;
    }
        
    [self getPath:@"posts" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)createPost:(Post *)post callbackBlock:(void (^)(BOOL success))callbackBlock
{
    if(ENV_FAKE_API) {
        callbackBlock(YES);
        return;
    }
    
    [self postPath:@"post" parameters:@{@"post": post} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)getCommentsForPost:(Post *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock
{
    if(ENV_FAKE_API) {
        User *user = [[User alloc] init];
        user.name = @"Tade";
        
        Comment *comment1 = [[Comment alloc] init];
        comment1.content = @"Comment 1";
        comment1.date = [NSDate date];
        comment1.socialContent.likes = 10;
        comment1.socialContent.hates = 5;
        comment1.user = user;
        
        Comment *comment2 = [[Comment alloc] init];
        comment2.content = @"Comment 2";
        comment2.date = [NSDate date];
        comment2.socialContent.likes = 10;
        comment2.socialContent.hates = 5;
        comment2.user = user;
        
        Comment *comment3 = [[Comment alloc] init];
        comment3.content = @"Comment 3";
        comment3.date = [NSDate date];
        comment3.socialContent.likes = 10;
        comment3.socialContent.hates = 5;
        comment3.user = user;
        
        NSArray *comments = [NSArray arrayWithObjects:comment1, comment2, comment3, nil];
        callbackBlock(YES, comments);
        return;
    }
}

- (void)createComment:(Comment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock
{
    if(ENV_FAKE_API) {
        callbackBlock(YES);
        return;
    }
}

- (void)getTopicsForCurrentUserWithCallbackBlock:(void (^)(BOOL success, NSArray *topics))callbackBlock
{
    if(ENV_FAKE_API) {
        User *user = [[User alloc] init];
        user.name = @"Tade";
        User *user2 = [[User alloc] init];
        user2.name = @"Patrick";
        NSArray *users = [NSArray arrayWithObjects:user, user2, nil];
        
        Topic *obj1 = [[Topic alloc] init];
        obj1.title = @"Topic 1";
        obj1.date = [NSDate date];
        obj1.users = users;
        obj1.user = user2;
        
        Topic *obj2 = [[Topic alloc] init];
        obj2.title = @"Topic 2";
        obj2.date = [NSDate date];
        obj2.users = users;
        obj2.user = user2;
        
        Topic *obj3 = [[Topic alloc] init];
        obj3.title = @"Topic 3";
        obj3.date = [NSDate date];
        obj3.users = users;
        obj3.user = user2;
        
        NSArray *objs = [NSArray arrayWithObjects:obj1, obj2, obj3, nil];
        callbackBlock(YES, objs);
        return;
    }
    
}

- (void)createTopic:(Topic *)topic callbackBlock:(void (^)(BOOL success))callbackBlock
{
    if(ENV_FAKE_API) {
        callbackBlock(YES);
        return;
    }
    
}


@end

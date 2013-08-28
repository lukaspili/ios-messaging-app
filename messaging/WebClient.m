//
//  WebClient.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "WebClient.h"
#import "OHHTTPStubs.h"
#import "AFJSONRequestOperation.h"
#import "SessionManager.h"
#import "JsonParser.h"


@interface WebClient()

@property (strong, nonatomic) NSDictionary *authParameters;
@property (strong, nonatomic) SessionManager *sessionManager;

@end

@implementation WebClient

static NSString * const kWebserviceBaseUrl = @"https://api.gleepost.com/v0.0/";

static WebClient *instance = nil;

+ (WebClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebClient alloc] initWithBaseURL:[NSURL URLWithString:kWebserviceBaseUrl]];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self) {
        return nil;
    }
    
    [self setParameterEncoding:AFFormURLParameterEncoding];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.sessionManager = [SessionManager sharedInstance];
    
    if(ENV_FAKE_API) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.absoluteString hasPrefix:kWebserviceBaseUrl];
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            NSString *path = request.URL.absoluteString.lastPathComponent;
            NSRange range = [path rangeOfString:@"?"];
            if(range.location != NSNotFound) {
                path = [path substringWithRange:NSMakeRange(0, range.location)];
            }
            
            NSString *filePath = [NSString stringWithFormat:@"%@_%@.json", [request.HTTPMethod lowercaseString], path];
            NSLog(@"mock filepath %@", filePath);
            return [OHHTTPStubsResponse responseWithFile:filePath contentType:@"text/json" responseTime:0.5];
        }];
    }
    
    return self;
}

- (void)loginWithName:(NSString *)name password:(NSString *)password andCallbackBlock:(void (^)(BOOL success))callbackBlock
{
    [self postPath:@"login" parameters:@{@"user": name, @"pass": password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = (NSDictionary *) responseObject;
        BOOL success = [json[@"success"] boolValue];
        
        if(!success) {
            callbackBlock(NO);
            return;
        }
        
        User *user = [[User alloc] init];
        user.name = @"lukas";
        user.remoteId = 1;
        
        self.sessionManager.user = user;
        self.sessionManager.token = json[@"token"][@"value"];
        
        self.authParameters = @{@"id": [NSString stringWithFormat:@"%d", user.remoteId], @"token": self.sessionManager.token};
        
        callbackBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)getPostsWithCallbackBlock:(void (^)(BOOL success, NSArray *posts))callbackBlock
{
    [self getPath:@"posts" parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = (NSDictionary *) responseObject;
        BOOL success = [json[@"success"] boolValue];
        
        if(!success) {
            callbackBlock(NO, nil);
            return;
        }
        
        NSArray *posts = [JsonParser parsePostsFromJson:json[@"posts"]];
        callbackBlock(YES, posts);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)createPost:(Post *)post callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"text", post.content, nil];
    [params addEntriesFromDictionary:self.authParameters];
    
    [self postPath:@"posts" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = (NSDictionary *)responseObject;
        BOOL success = [json[@"success"] boolValue];
        callbackBlock(success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)getCommentsForPost:(Post *)post withCallbackBlock:(void (^)(BOOL success, NSArray *comments))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/comments", post.remoteId];
    [self getPath:path parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = (NSDictionary *) responseObject;
        BOOL success = [json[@"success"] boolValue];
        
        if(!success) {
            callbackBlock(NO, nil);
            return;
        }
        
        NSArray *comments = [JsonParser parseCommentsFromJson:json[@"comments"]];
        callbackBlock(YES, comments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];

}

- (void)createComment:(Comment *)comment callbackBlock:(void (^)(BOOL success))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"posts/%d/comments", comment.remoteThreadId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"text", comment.content, nil];
    [params addEntriesFromDictionary:self.authParameters];
    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = (NSDictionary *)responseObject;
        BOOL success = [json[@"success"] boolValue];
        callbackBlock(success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO);
    }];
}

- (void)getConversationsWithCallbackBlock:(void (^)(BOOL success, NSArray *conversations))callbackBlock
{
    [self getPath:@"conversations" parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = (NSDictionary *) responseObject;
        BOOL success = [json[@"success"] boolValue];
        
        if(!success) {
            callbackBlock(NO, nil);
            return;
        }
        
        NSArray *conversations = [JsonParser parseConversationsFromJson:json[@"conversations"]];
        callbackBlock(YES, conversations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callbackBlock(NO, nil);
    }];
}

- (void)getMessagesForConversation:(Conversation *)conversation withCallbackBlock:(void (^)(BOOL success, NSArray *messages))callbackBlock
{
    NSString *path = [NSString stringWithFormat:@"conversations/%d/messages", conversation.remoteId];
    [self getPath:path parameters:self.authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *json = (NSDictionary *) responseObject;
        BOOL success = [json[@"success"] boolValue];
        
        if(!success) {
            callbackBlock(NO, nil);
            return;
        }
        
        NSArray *messages = [JsonParser parseMessagesFromJson:json[@"conversation"][@"messages"]];
        callbackBlock(YES, messages);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        callbackBlock(NO, nil);
    }];
}

- (void)createTopic:(Topic *)topic callbackBlock:(void (^)(BOOL success))callbackBlock
{
    if(ENV_FAKE_API) {
        callbackBlock(YES);
        return;
    }
    
}


@end

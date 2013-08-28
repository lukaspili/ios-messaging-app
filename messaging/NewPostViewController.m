//
//  NewPostViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewPostViewController.h"
#import "TimelineViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "UIPlaceHolderTextView.h"
#import "Post.h"

@interface NewPostViewController ()

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)postButtonClick:(id)sender;

@end

@implementation NewPostViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.contentTextView becomeFirstResponder];
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonClick:(id)sender
{
    [self.contentTextView resignFirstResponder];
    
    Post *post = [[Post alloc] init];
    post.content = self.contentTextView.text;
    post.date = [NSDate date];
    post.remoteUserId = [SessionManager sharedInstance].user.remoteId;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Creating post";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client createPost:post callbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate loadPosts];
            }];
        } else {
            [self.contentTextView becomeFirstResponder];
        }
    }];
}
@end

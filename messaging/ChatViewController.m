//
//  ChatViewController.m
//  messaging
//
//  Created by Lukas on 8/29/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ChatViewController.h"
#import "ViewTopicViewController.h"
#import "MBProgressHUD.h"
#import "WebClient.h"

@interface ChatViewController ()

@property (strong, nonatomic) Conversation *conversation;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)startGroupButtonClicked:(id)sender;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)startButtonClicked:(id)sender
{
    [self searchForConversationForGroup:NO];
}

- (IBAction)startGroupButtonClicked:(id)sender
{
    [self searchForConversationForGroup:YES];
}

- (void)searchForConversationForGroup:(BOOL)group
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Looking for people";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    
    void(^block)(BOOL success, Conversation *conversation);
    block = ^(BOOL success, Conversation *conversation) {
        [hud hide:YES];
        
        if(success) {
            self.conversation = conversation;
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Conversation failed"
                                                            message:@"Check your your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    };
    
    if(group) {
        [client createGroupConversationWithCallbackBlock:block];
    } else {
        [client createOneToOneConversationWithCallbackBlock:block];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"start"]) {
        ViewTopicViewController *vc = segue.destinationViewController;
        vc.conversation = self.conversation;
    }
}
@end

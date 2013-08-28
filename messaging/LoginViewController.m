//
//  LoginViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SessionManager.h"
#import "WebClient.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonClick:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

- (IBAction)loginButtonClick:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Login...";
    hud.detailsLabelText = @"Please wait";
    
    WebClient *client = [WebClient sharedInstance];
    [client loginWithName:self.nameTextField.text password:self.passwordTextField.text andCallbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self performSegueWithIdentifier:@"start" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed"
                                                            message:@"Check your identifiers or your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}
@end

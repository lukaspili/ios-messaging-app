//
//  ViewTopicViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "ViewTopicViewController.h"
#import "WebClient.h"
#import "MBProgressHUD.h"
#import "Message.h"
#import "KeyboardHelper.h"
#import "NSString+Utils.h"

@interface ViewTopicViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (assign, nonatomic) float keyboardAppearanceSpaceY;
@property (strong, nonatomic) NSMutableArray *messages;

- (IBAction)sendButtonClicked:(id)sender;
- (IBAction)tableViewClicked:(id)sender;

@end

@implementation ViewTopicViewController

@synthesize conversation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.conversation getParticipantsNames];
    
    self.keyboardAppearanceSpaceY = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    
    [self loadMessages];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadMessages
{
    id view = ([self.messageTextField isFirstResponder]) ? [[UIApplication sharedApplication].windows objectAtIndex:1] : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = @"Loading messages";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client getMessagesForConversation:self.conversation withCallbackBlock:^(BOOL success, NSArray *messages) {
        [hud hide:YES];
        
        if(success) {
            self.messages = [messages mutableCopy];
//            [self.messages addObjectsFromArray:self.messages];
//            [self.messages addObjectsFromArray:self.messages];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
                                                            message:@"Check your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Message *message = self.messages[indexPath.row];
    cell.textLabel.text = message.content;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Sent by %@", message.author.name];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)sendButtonClicked:(id)sender
{
    if([self.messageTextField.text isEmpty]) {
        return;
    }
    
    Message *message = [[Message alloc] init];
    message.content = self.messageTextField.text;
    message.conversationRemoteId = self.conversation.remoteId;
    
    id view = ([self.messageTextField isFirstResponder]) ? [[UIApplication sharedApplication].windows objectAtIndex:1] : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = @"Sending message";
    hud.detailsLabelText = @"Please wait few seconds";
    
    [[WebClient sharedInstance] createMessage:message callbackBlock:^(BOOL success) {
        [hud hide:YES];
        
        if(success) {
            [self loadMessages];
            self.messageTextField.text = @"";
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending message failed"
                                                            message:@"Check your internet connection, dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)tableViewClicked:(id)sender
{
    [self hideKeyboardFromTextViewIfNeeded];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSelector:@selector(sendButtonClicked:) withObject:self];
    return YES;
}



- (void)hideKeyboardFromTextViewIfNeeded
{
    if([self.messageTextField isFirstResponder]) {
        [self.messageTextField resignFirstResponder];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self hideKeyboardFromTextViewIfNeeded];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(self.keyboardAppearanceSpaceY != 0) {
        return;
    }
    
    float height = [KeyboardHelper keyboardHeight:notification] - 49;
    self.keyboardAppearanceSpaceY = height;
    
    [self animateViewWithVerticalMovement:-self.keyboardAppearanceSpaceY duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animateViewWithVerticalMovement:fabs(self.keyboardAppearanceSpaceY) duration:[KeyboardHelper keyboardAnimationDuration:notification] andAnimationOptions:[KeyboardHelper keyboardAnimationOptions:notification]];
    self.keyboardAppearanceSpaceY = 0;
}

- (void) animateViewWithVerticalMovement:(float)movement duration:(float)duration andAnimationOptions:(UIViewAnimationOptions)animationOptions
{
    [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{

        self.messageView.frame = CGRectOffset(self.messageView.frame, 0, movement);
    } completion:^(BOOL finished) {
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + (movement));
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

@end

//
//  TimelineViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "TimelineViewController.h"
#import "ViewPostViewController.h"
#import "NewPostViewController.h"
#import "WebClient.h"
#import "MBProgressHUD.h"
#import "Post.h"
#import "PostCell.h"

@interface TimelineViewController ()

@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) Post *selectedPost;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TimelineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"navigation_bar.png"];
//    UIImage* tabBarBackground = [UIImage imageNamed:@"navigation_fullblack.png"];
//    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
//    
//    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"navigation_select.png"]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_post.png"]]];
//    [item.target addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = item;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_post.png"]];
    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(newPostButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = imageView.bounds;
    [imageView addSubview:btnBack];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
//    UIButton *btnBack=[UIButton buttonWithType:UIButtonTypeCustom];
//
//    [btnBack setImage:[UIImage imageNamed:@"new_post.png"] forState:UIControlStateNormal];
//    [btnBack setFrame:CGRectMake(0, 0, 79, 30)];
//    UIView *backModifiedView=[[UIView alloc] initWithFrame:btnBack.frame];
//    [btnBack setFrame:CGRectMake(btnBack.frame.origin.x, btnBack.frame.origin.y+7, btnBack.frame.size.width, btnBack.frame.size.height)];
//    [backModifiedView addSubview:btnBack];
//    UIBarButtonItem *bbiLeft=[[UIBarButtonItem alloc] initWithCustomView:backModifiedView];
//    self.navigationItem.rightBarButtonItem=bbiLeft;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self loadPosts];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadPosts
{
    NSLog(@"load posts");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading posts";
    hud.detailsLabelText = @"Please wait few seconds";
    
    WebClient *client = [WebClient sharedInstance];
    [client getPostsWithCallbackBlock:^(BOOL success, NSArray *posts) {
        [hud hide:YES];
        
        if(success) {
            self.posts = [posts mutableCopy];
            [self.tableView reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading failed"
                                                            message:@"Check your id or your internet connection dude."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Post *post = self.posts[indexPath.row];
    cell.contentLabel.text = post.content;
    cell.dateLabel.text = [self.dateFormatter stringFromDate:post.date];
    cell.userLabel.text = post.user.name;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
//    cell.textLabel.text = post.content;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", post.user.name, [self.dateFormatter stringFromDate:post.date]];
    
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
    self.selectedPost = self.posts[indexPath.row];
    [self performSegueWithIdentifier:@"view post" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


- (void)newPostButtonClick
{
    [self performSegueWithIdentifier:@"new post" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"view post"]) {
        ViewPostViewController *vc = segue.destinationViewController;
        vc.post = self.selectedPost;
        self.selectedPost = nil;
    } else if([segue.identifier isEqualToString:@"new post"]) {
        NewPostViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

@end

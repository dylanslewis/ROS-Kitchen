//
//  OrderItemManagerViewController.m
//  Kitchen
//
//  Created by Dylan Lewis on 08/10/2014.
//  Copyright (c) 2014 Dylan Lewis. All rights reserved.
//

#import "OrderItemManagerViewController.h"
#import <Parse/Parse.h>
#import "NewOrderItemTableViewCell.h"
#import "UIImage+ImageEffects.h"
#import "AcceptItemViewController.h"

@interface OrderItemManagerViewController ()

@property (strong, nonatomic) NSArray *orderItemsArray;

@end

@implementation OrderItemManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getParseData];
}

- (void)viewDidAppear:(BOOL)animated {
    // Get the current user.
    PFUser *user=[PFUser currentUser];
    
    // If there is no user logged in, return to the login screen.
    if (!user) {
        [self performSegueWithIdentifier:@"logoutUserSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Button handling

- (IBAction)didTouchAcceptNewOrderButton:(id)sender {
    NewOrderItemTableViewCell *touchedCell = (NewOrderItemTableViewCell *)[[sender superview] superview];
    
    PFObject *orderItem = [touchedCell orderItemObject];
    
    [self performSegueWithIdentifier:@"acceptItemSegue" sender:orderItem];
}

- (IBAction)didTouchRejectNewOrderButton:(id)sender {
}



#pragma mark - Translucency effects

// All translucency code adapted from http://stackoverflow.com/questions/19177348/ios-7-translucent-modal-view-controller

-(UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)makeTranslucent:(UIImage *)image {
    image = [self convertViewToImage:self.view];
    image = [image applyBlurWithRadius:20
                                             tintColor:[UIColor colorWithWhite:1.0 alpha:0.2]
                                 saturationDeltaFactor:1.3
                                             maskImage:nil];
    
    return image;
}



#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
/*
    // Get the key for this section from the dictionary.
    NSString *key = [[_orderItemSections allKeys] objectAtIndex:section];
    
    // Get the order item objects belonging to this key, and store in an array.
    NSArray *orderItemsForKey = [_orderItemSections valueForKey:key];
    
    return [orderItemsForKey count];
    */
    return [_orderItemsArray count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[_orderItemSections allKeys] objectAtIndex:section];
}
 */

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Code for method adapted from: http://stackoverflow.com/questions/15611374/customize-uitableview-header-section
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont systemFontOfSize:14]];
    label.textColor = [UIColor grayColor];
    
    NSString *string = [[_orderItemSections allKeys] objectAtIndex:section];
    
    [label setText:string];
    [view addSubview:label];
    
    // Set background colour for header.
    [view setBackgroundColor:[UIColor whiteColor]];
    
    return view;
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"newOrderItemCell";

    NewOrderItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *orderItem = [_orderItemsArray objectAtIndex:[indexPath row]];
    
    cell.orderItemNameLabel.text = orderItem[@"name"];
    cell.orderItemObject = orderItem;
    
    return cell;
}


#pragma mark - Parse

- (void)getParseData {
    // Get order items for this order.
    PFQuery *getOrderItems = [PFQuery queryWithClassName:@"OrderItem"];
    [getOrderItems whereKey:@"state" equalTo:@"new"];
    [getOrderItems whereKey:@"type" equalTo:@"Food"];
    
    [getOrderItems findObjectsInBackgroundWithBlock:^(NSArray *orderItems, NSError *error) {
        if (!error) {
            // Create an array of all order items.
            _orderItemsArray = [[NSArray alloc] initWithArray:orderItems];
            //_orderItemSections = [[NSMutableDictionary alloc] init];
            
            // Go through the 'raw' list of order items.
            for (NSDictionary *orderItem in _orderItemsArray) {
                // Extract the current item's course.
                NSString *courseName=[orderItem valueForKey:@"course"];
                
                /*
                // If we don't already have this course, add it.
                if (![[_orderItemSections allKeys] containsObject:courseName]) {
                    // Create an array containing the current order item object.
                    NSMutableArray *orderItemsForCourse = [[NSMutableArray alloc] initWithObjects:orderItem, nil];
                    
                    [_orderItemSections setObject:orderItemsForCourse forKey:courseName];
                } else {
                    // If the key (i.e. course) already exists, add this order item to its array.
                    NSMutableArray *orderItemsForCourse = [_orderItemSections valueForKey:courseName];
                    [orderItemsForCourse addObject:orderItem];
                    
                    [_orderItemSections setObject:orderItemsForCourse forKey:courseName];
                }
                 */
            }
        }
        
        // Reload the table.
        [newOrdersTable reloadData];
    }];
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // This stops the button automatically logging in the user, without checking credentials.
    if ([identifier isEqualToString:@"logoutUserSegue"]) {
        return NO;
    } else if ([identifier isEqualToString:@"acceptItemSegue"]) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"acceptItemSegue"]) {
        UIImage *currentBackground = [self makeTranslucent:[self convertViewToImage:self.view]];
        
        PFObject *orderItem = (PFObject *)sender;
        
        [[segue destinationViewController] setTranslucentBackground:currentBackground];
        [[segue destinationViewController] setOrderItem:orderItem];
    }
}

@end
